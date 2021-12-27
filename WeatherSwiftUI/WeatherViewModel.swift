//
//  WeatherViewModel.swift
//  WeatherSwiftUI
//
//  Created by César González on 27/12/21.
//

import Foundation
import WeatherChallenge

class WeatherViewModel: ObservableObject {
    private let iconDict = ["Drizzle": "cloud.drizzle.fill",
                           "Thunderstorm": "cloud.sun.bolt.fill",
                           "Rain": "cloud.rain.fill",
                           "Snow": "cloud.snow.fill",
                           "Clear": "sun.max.fill",
                           "Clouds": "cloud.fill",
                           "Smoke": "smoke.fill"]
    
    @Published var cityName = "City Name"
    @Published var temperature = "--"
    @Published var weatherDescription = "--"
    @Published var weatherIcon: String = "cloud.sun.bolt.fill"
    @Published var backgroundImageName: String?
    
    private var loader: WeatherLoader
    
    init(loader: WeatherLoader) {
        self.loader = loader
    }
    
    func refresh() {
        loader.load { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let weather):
                    DispatchQueue.main.async {
                        self.cityName = weather.cityName
                        self.temperature = "\(Int(weather.temperature))ºC"
                        self.weatherDescription = weather.description
                        self.weatherIcon = self.iconDict[weather.iconName] ?? "moon.fill"
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
}
