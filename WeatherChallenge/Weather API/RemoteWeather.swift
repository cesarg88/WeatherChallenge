//
//  RemoteWeather.swift
//  WeatherChallenge
//
//  Created by César González on 27/12/21.
//

import Foundation

// MARK: - RemoteWeather
public struct RemoteWeather: Codable {
    public let coord: Coord
    public let weather: [WeatherItem]
    public let main: Main
    public let name: String
}

// MARK: - Coord
public struct Coord: Codable {
    public let lon, lat: Double
}

// MARK: - Main
public struct Main: Codable {
    public let temp, feelsLike, tempMin, tempMax: Double
    public let pressure, humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

// MARK: - Weather
public struct WeatherItem: Codable {
    public let id: Int
    public let main, weatherDescription, icon: String

    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}
