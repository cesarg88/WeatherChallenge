//
//  Presenter.swift
//  WeatheriOS
//
//  Created by César González on 27/12/21.
//

import Foundation
import WeatherChallenge

public protocol PresenterProtocol {
    var view: ViewProtocol? { get set }
    func viewDidLoadAction()
    func reloadAction()
}

public final class Presenter: PresenterProtocol {
    
    private var loader: WeatherLoader
    
    weak public var view: ViewProtocol?
    
    private let iconDict = ["Drizzle": "cloud.drizzle.fill",
                           "Thunderstorm": "cloud.sun.bolt.fill",
                           "Rain": "cloud.rain.fill",
                           "Snow": "cloud.snow.fill",
                           "Clear": "sun.max.fill",
                           "Clouds": "cloud.fill",
                           "Smoke": "smoke.fill"]
    
    public init(loader: WeatherLoader) {
        self.loader = loader
    }
    
    public func viewDidLoadAction() {
        loadWeatherForLocation(type: .initial)
    }
        
    public func reloadAction() {
        loadWeatherForLocation(type: .random)
    }
    
    private func loadWeatherForLocation(type: LocationType) {
        loader.loadWeatherFor(locationType: type) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let weather):
                    if weather.cityName.isEmpty {
                        self.reloadAction()
                        return
                    }
                    self.view?.display(self.createViewModelFrom(weather))
                case .failure:
                    self.view?.displayErrorWith(text: "something went wrong, please try again")
            }
        }
    }
    
    private func createViewModelFrom(_ weather: Weather) -> ViewModel {
        ViewModel(
            coords: weather.location,
            cityName: weather.cityName,
            temperature: "\(Int(weather.temperature))ºC",
            weatherDescription: weather.description,
            weatherIcon: self.iconDict[weather.iconName] ?? "moon.fill")
    }
}


