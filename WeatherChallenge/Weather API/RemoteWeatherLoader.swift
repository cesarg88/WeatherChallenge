//
//  RemoteWeatherLoader.swift
//  WeatherChallenge
//
//  Created by César González on 27/12/21.
//

import Foundation
import CoreLocation

public final class RemoteWeatherLoader: WeatherLoader {
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity, invalidData
    }
  
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func loadWeatherFor(locationType: LocationType, completion: @escaping (WeatherLoader.Result) -> Void) {
        let url = LocationURLCreator.makeURLFor(type: locationType)
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
        return Weather(location: CLLocationCoordinate2D(latitude: self.coord.lat, longitude: self.coord.lon),
                       cityName: self.name,
                       temperature: self.main.temp,
                       description: self.weather.first?.weatherDescription ?? "",
                       iconName: self.weather.first?.icon ?? "" )
    }
}

