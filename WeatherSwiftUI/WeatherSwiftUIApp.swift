//
//  WeatherSwiftUIApp.swift
//  WeatherSwiftUI
//
//  Created by César González Palomino on 27/12/21.
//

import SwiftUI
import WeatherChallenge

@main
struct WeatherSwiftUIApp: App {
    var body: some Scene {
        let client = URLSessionHTTPClient(session: URLSession.shared)
        let string = "https://api.openweathermap.org/data/2.5/weather?lat=40.416775&lon=-3.70379&appid=b4ccaaeb72655067d09d3c0da0a6de92&units=metric&lang=es".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: string)!
        let loader = RemoteWeatherLoader(url: url, client: client)
        WindowGroup {
            WeatherView(viewModel: WeatherViewModel(loader: loader))
        }
    }
}
