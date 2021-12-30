//
//  ViewModel.swift
//  WeatheriOS
//
//  Created by César González on 27/12/21.
//

import Foundation

public struct ViewModel {
    public let latitude: String
    public let longitude: String
    public let cityName: String
    public let temperature: String
    public let weatherDescription: String
    public let weatherIcon: String
    
    public init(latitude: String,
                longitude: String,
                cityName: String,
                temperature: String,
                weatherDescription: String,
                weatherIcon: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.cityName = cityName
        self.temperature = temperature
        self.weatherDescription = weatherDescription
        self.weatherIcon = weatherIcon
    }
}
