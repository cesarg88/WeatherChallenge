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
    
    static func makeURLFor(type: LocationType) -> URL {
        let location: CLLocationCoordinate2D = type == .initial ? initialLocation : generateRandomCoordinates(currentLocation: initialLocation)
        let string = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=b4ccaaeb72655067d09d3c0da0a6de92&units=metric&lang=es".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return  URL(string: string)!
    }
    
    private static func generateRandomCoordinates(currentLocation: CLLocationCoordinate2D, min: UInt32 = 7000, max: UInt32 = 2000000) -> CLLocationCoordinate2D {
        
        //Get the Current Location's longitude and latitude
        let currentLong = currentLocation.longitude
        let currentLat = currentLocation.latitude

        //1 KiloMeter = 0.00900900900901° So, 1 Meter = 0.00900900900901 / 1000
        let meterCord = 0.00900900900901 / 1000

        //Generate random Meters between the maximum and minimum Meters
        let randomMeters = UInt(arc4random_uniform(max) + min)

        //then Generating Random numbers for different Methods
        let randomPM = arc4random_uniform(6)

        //Then we convert the distance in meters to coordinates by Multiplying the number of meters with 1 Meter Coordinate
        let metersCordN = meterCord * Double(randomMeters)

        //here we generate the last Coordinates
        if randomPM == 0 {
            return CLLocationCoordinate2D(latitude: currentLat + metersCordN, longitude: currentLong + metersCordN)
        } else if randomPM == 1 {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong - metersCordN)
        } else if randomPM == 2 {
            return CLLocationCoordinate2D(latitude: currentLat + metersCordN, longitude: currentLong - metersCordN)
        } else if randomPM == 3 {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong + metersCordN)
        } else if randomPM == 4 {
            return CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong - metersCordN)
        } else {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong)
        }
    }
}
