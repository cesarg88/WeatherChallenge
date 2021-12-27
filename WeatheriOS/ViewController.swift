//
//  ViewController.swift
//  WeatheriOS
//
//  Created by César González on 27/12/21.
//

import UIKit
import WeatherChallenge

protocol PresenterProtocol {
    func viewDidLoadAction()
}

final class Presenter: PresenterProtocol {
    
    private var loader: WeatherLoader
    
    private let iconDict = ["Drizzle": "cloud.drizzle.fill",
                           "Thunderstorm": "cloud.sun.bolt.fill",
                           "Rain": "cloud.rain.fill",
                           "Snow": "cloud.snow.fill",
                           "Clear": "sun.max.fill",
                           "Clouds": "cloud.fill",
                           "Smoke": "smoke.fill"]
    
    init(loader: WeatherLoader) {
        self.loader = loader
    }
    
    func viewDidLoadAction() {
        print("viewDidLoadAction called")
        loader.load { [weak self] result in
            switch result {
                case .success(let weather):
                    let viewModel = ViewModel(
                        latitude: "\(weather.latitude)",
                        longitude: "\(weather.longitude)",
                        cityName: weather.cityName,
                        temperature: "\(weather.temperature)ºC",
                        weatherDescription: weather.description,
                        weatherIcon: self!.iconDict[weather.iconName] ?? "moon.fill")
                    print(viewModel)
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
}

struct ViewModel {
    var latitude: String
    var longitude: String
    var cityName: String
    var temperature: String
    var weatherDescription: String
    var weatherIcon: String
}

final class ViewController: UIViewController {
    
    private let presenter: PresenterProtocol
    
    init?(coder: NSCoder, presenter: PresenterProtocol) {
        self.presenter = presenter
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoadAction()
    }


}

