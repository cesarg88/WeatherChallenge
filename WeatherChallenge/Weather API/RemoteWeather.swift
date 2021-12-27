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
    public let temp: Double
}

// MARK: - Weather
public struct WeatherItem: Codable {
    public let id: Int
    public let weatherDescription, icon: String

    enum CodingKeys: String, CodingKey {
        case id
        case weatherDescription = "description"
        case icon = "main"
    }
}
