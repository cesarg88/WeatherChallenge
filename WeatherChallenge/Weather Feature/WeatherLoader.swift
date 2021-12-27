//
//  WeatherLoader.swift
//  WeatherChallenge
//
//  Created by César González on 27/12/21.
//

import Foundation

public protocol WeatherLoader {
    typealias Result = Swift.Result<Weather, Error>
    func load(completion: @escaping (Result) -> Void)
}

public struct Weather {
    let latitude: Double
    let longitude: Double
    let cityName: String
    let temperature: Double
    let description: String?
    let iconName: String?
    
    public init(latitude: Double,
                longitude: Double,
                cityName: String,
                temperature: Double,
                description: String?,
                iconName: String?) {
        self.latitude = latitude
        self.longitude = longitude
        self.cityName = cityName
        self.temperature = temperature
        self.description = description
        self.iconName = iconName
    }
}
