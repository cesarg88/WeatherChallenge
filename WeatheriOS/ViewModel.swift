//
//  ViewModel.swift
//  WeatheriOS
//
//  Created by César González on 27/12/21.
//

import Foundation
import CoreLocation

public struct ViewModel {
    public var coords: CLLocationCoordinate2D
//    public var latitude: String
//    public var longitude: String
    public var cityName: String
    public var temperature: String
    public var weatherDescription: String
    public var weatherIcon: String
    
    public init(coords: CLLocationCoordinate2D,
                cityName: String,
                temperature: String,
                weatherDescription: String,
                weatherIcon: String) {
//        self.latitude = latitude
//        self.longitude = longitude
        self.coords = coords
        self.cityName = cityName
        self.temperature = temperature
        self.weatherDescription = weatherDescription
        self.weatherIcon = weatherIcon
    }
}
