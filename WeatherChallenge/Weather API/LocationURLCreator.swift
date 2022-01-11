//
//  LocationURLCreator.swift
//  WeatherChallenge
//
//  Created by César González on 28/12/21.
//

import Foundation
import CoreLocation

final class LocationURLCreator {
    
    private static var initialLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 40.416775, longitude: -3.70379)
    }
    
    static func makeURL() -> URL {
        let location = generateRandomCoordinates()
        let string = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=b4ccaaeb72655067d09d3c0da0a6de92&units=metric&lang=es".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return  URL(string: string)!
    }
    
    private static func generateRandomCoordinates() -> CLLocationCoordinate2D {
        
        let latitude = Double.random(in: -90.0 ... 90.0)
        let longitude = Double.random(in: -180.0 ... 180.0)
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
