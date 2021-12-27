//
//  WeatherMapper.swift
//  WeatherChallenge
//
//  Created by César González on 27/12/21.
//

import Foundation

final class WeatherMapper {

    private static var OK_200: Int { 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteWeather {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(RemoteWeather.self, from: data)
        else { throw RemoteWeatherLoader.Error.invalidData }
        return root
    }
}
