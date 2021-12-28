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
    
    public func loadWeatherFor(location: CLLocationCoordinate2D, completion: @escaping (WeatherLoader.Result) -> Void) {
        let url = makeURLFor(location: location)
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
    
    private func makeURLFor(location: CLLocationCoordinate2D) -> URL {
        let string = "https://api.openweathermap.org/data/2.5/weather?lat=40.416775&lon=-3.70379&appid=b4ccaaeb72655067d09d3c0da0a6de92&units=metric&lang=es".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return  URL(string: string)!
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
