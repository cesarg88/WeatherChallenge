//
//  ViewModel.swift
//  WeatheriOS
//
//  Created by César González on 27/12/21.
//

import Foundation

public struct ViewModel {
    public var latitude: String
    public var longitude: String
    public var cityName: String
    public var temperature: String
    public var weatherDescription: String
    public var weatherIcon: String
    
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
