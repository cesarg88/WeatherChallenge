//
//  WeatherLoader.swift
//  WeatherChallenge
//
//  Created by César González on 27/12/21.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[Weather], Error>
    func load(completion: @escaping (Result) -> Void)
}

public struct Weather {
    let latitude: Int
    let longitude: Int
    let cityName: String
    let temperature: String
    let iconName: String
}
