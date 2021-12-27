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

public struct Weather: Equatable {
    public let latitude: Double
    public let longitude: Double
    public let cityName: String
    public let temperature: Double
    public let description: String
    public let iconName: String
    
    public init(latitude: Double,
                longitude: Double,
                cityName: String,
                temperature: Double,
                description: String,
                iconName: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.cityName = cityName
        self.temperature = temperature
        self.description = description
        self.iconName = iconName
    }
}
