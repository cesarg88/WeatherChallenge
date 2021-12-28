//
//  Presenter.swift
//  WeatheriOS
//
//  Created by César González on 27/12/21.
//

import Foundation
import WeatherChallenge

protocol PresenterProtocol {
    var view: ViewProtocol? { get set }
    func viewDidLoadAction()
    func reloadAction()
}

final class Presenter: PresenterProtocol {
    
    private var loader: WeatherLoader
    
    weak var view: ViewProtocol?
    
    private let iconDict = ["Drizzle": "cloud.drizzle.fill",
                           "Thunderstorm": "cloud.sun.bolt.fill",
                           "Rain": "cloud.rain.fill",
                           "Snow": "cloud.snow.fill",
                           "Clear": "sun.max.fill",
                           "Clouds": "cloud.fill",
                           "Smoke": "smoke.fill"]
    
    init(loader: WeatherLoader) {
        self.loader = loader
    }
    
    func viewDidLoadAction() {
        loadWeatherForLocation(type: .initial)
    }
        
    func reloadAction() {
        loadWeatherForLocation(type: .random)
    }
    
    private func loadWeatherForLocation(type: LocationType) {
        loader.loadWeatherFor(locationType: type) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let weather):
                    let viewModel = ViewModel(
                        latitude: "latitud: \(weather.location.latitude)",
                        longitude: "longitud: \(weather.location.longitude)",
                        cityName: weather.cityName,
                        temperature: "\(Int(weather.temperature))ºC",
                        weatherDescription: weather.description,
                        weatherIcon: self.iconDict[weather.iconName] ?? "moon.fill")
                    DispatchQueue.main.async {
                        self.view?.display(viewModel)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
}


