//
//  ViewModel.swift
//  WeatheriOS
//
//  Created by César González on 27/12/21.
//

import CoreLocation

public struct ViewModel {
    public let coords: CLLocationCoordinate2D
    public let cityName: String
    public let temperature: String
    public let weatherDescription: String
    public let weatherIcon: String
    
    public init(coords: CLLocationCoordinate2D,
                cityName: String,
                temperature: String,
                weatherDescription: String,
                weatherIcon: String) {
        self.coords = coords
        self.cityName = cityName
        self.temperature = temperature
        self.weatherDescription = weatherDescription
        self.weatherIcon = weatherIcon
    }
}
