//
//  WeatherLoader.swift
//  WeatherChallenge
//
//  Created by César González on 27/12/21.
//

import Foundation
import CoreLocation

public protocol WeatherLoader {
    typealias Result = Swift.Result<Weather, Error>
    func loadWeatherFor(location: CLLocationCoordinate2D, completion: @escaping (Result) -> Void)
}

public struct Weather: Equatable {
    public let location: CLLocationCoordinate2D
    public let cityName: String
    public let temperature: Double
    public let description: String
    public let iconName: String
    
    public init(location: CLLocationCoordinate2D,
                cityName: String,
                temperature: Double,
                description: String,
                iconName: String) {
        self.cityName = cityName
        self.temperature = temperature
        self.description = description
        self.iconName = iconName
        self.location = location
    }
}

extension CLLocationCoordinate2D: Equatable {
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    static func != (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude != rhs.latitude && lhs.longitude != rhs.longitude
    }
    
}
