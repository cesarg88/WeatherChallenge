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
        let loader = RemoteWeatherLoader(client: client)
        WindowGroup {
            WeatherView(viewModel: WeatherViewModel(loader: loader))
        }
    }
}
