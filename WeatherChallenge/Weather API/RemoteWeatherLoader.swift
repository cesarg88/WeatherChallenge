//
//  RemoteWeatherLoader.swift
//  WeatherChallenge
//
//  Created by César González on 27/12/21.
//

import Foundation

public final class RemoteWeatherLoader: WeatherLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity, invalidData
    }
  
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (WeatherLoader.Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
                case let .success((data, response)):
                    completion(RemoteWeatherLoader.map(data, from: response))
                case .failure:
                    completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> WeatherLoader.Result {
        do {
            let remoteWeather = try WeatherMapper.map(data, from: response)
            return .success(remoteWeather.toModel())
        } catch {
            return .failure(error)
        }
    }
}

private extension RemoteWeather {
    func toModel() -> Weather {
        return Weather(latitude: self.coord.lat,
                       longitude: self.coord.lon,
                       cityName: self.name,
                       temperature: self.main.temp,
                       description: self.weather.first?.weatherDescription ?? "",
                       iconName: self.weather.first?.icon ?? "" )
    }
}
