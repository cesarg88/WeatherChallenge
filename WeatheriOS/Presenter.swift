//
//  Presenter.swift
//  WeatheriOS
//
//  Created by César González on 27/12/21.
//

import Foundation
import WeatherChallenge
import CoreLocation

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
    
    private var initialLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 40.416775, longitude: -3.70379)
    }
    
    init(loader: WeatherLoader) {
        self.loader = loader
    }
    
    func viewDidLoadAction() {
        loadWeatherForLocation(initialLocation)
    }
    
    func reloadAction() {
        
    }
    
    private func loadWeatherForLocation(_ location: CLLocationCoordinate2D) {
        loader.loadFor(location: location) { [weak self] result in
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
