//
//  WeatheriOSTests.swift
//  WeatheriOSTests
//
//  Created by César González on 27/12/21.
//

import XCTest
import WeatheriOS
import WeatherChallenge
import CoreLocation

final class WeatherViewcontrollerTests: XCTestCase {

    func test_viewDidLoad_requestWeatherFromPresenter() {
        let (sut, presenter) = makeSUT()
        XCTAssertEqual(presenter.loadCount, 0, "Expected no loading requests before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(presenter.loadCount, 1, "Expected a loading request once view is loaded")
        sut.changeLocation()
        XCTAssertEqual(presenter.loadCount, 2, "Expected another loading request once user initiates a reload")

        sut.changeLocation()
        XCTAssertEqual(presenter.loadCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_displayViewModel_shouldDisplayCorrectData() {
        let (sut, presenter) = makeSUT()
        let (_, viewModel) = makeWeather(location: CLLocationCoordinate2D(latitude: 1.23, longitude: 2.34),
                                  cityName: "Madrid",
                                  temperature: 12.5,
                                  description: "sunny",
                                  iconName: "sunny")
        sut.loadViewIfNeeded()
        presenter.completeLoading(with: viewModel)
        XCTAssertEqual(sut.cityNameLabel.text, viewModel.cityName)
        XCTAssertEqual(sut.temperatureLabel.text, viewModel.temperature)
        XCTAssertEqual(sut.descriptionLabel.text, viewModel.weatherDescription)
        XCTAssertEqual(sut.latitudLabel.text, viewModel.latitude)
        XCTAssertEqual(sut.longitudLabel.text, viewModel.longitude)
    }
    
    func test_displayViewModel_shouldNotShowErrorView() {
        let (sut, presenter) = makeSUT()
        let (_, viewModel) = makeWeather(location: CLLocationCoordinate2D(latitude: 1.23, longitude: 2.34),
                                  cityName: "Madrid",
                                  temperature: 12.5,
                                  description: "sunny",
                                  iconName: "sunny")
        sut.loadViewIfNeeded()
        presenter.completeLoading(with: viewModel)
        XCTAssertNil(sut.errorView)
    }
    
    func test_displayError_shouldDisplayErrorView() {
        let (sut, presenter) = makeSUT()
        sut.loadViewIfNeeded()
        presenter.completeWithError()
        XCTAssert(sut.errorView != nil)
    }
    
    func test_changeLocation_shouldHideErrorView() {
        let (sut, presenter) = makeSUT()
        let (_, viewModel) = makeWeather(location: CLLocationCoordinate2D(latitude: 1.23, longitude: 2.34),
                                  cityName: "Madrid",
                                  temperature: 12.5,
                                  description: "sunny",
                                  iconName: "sunny")
        sut.loadViewIfNeeded()
        presenter.completeLoading(with: viewModel)
        sut.changeLocation()
        presenter.completeWithError()
        sut.changeLocation()
        XCTAssert(sut.errorView == nil)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ViewController, presenter: PresenterSpy) {
        let presenter = PresenterSpy()
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: ViewController.self))
        let sut = storyboard.instantiateViewController(identifier: "viewController", creator: { coder in
            return ViewController(coder: coder,
                                  presenter: presenter)
        })
        presenter.view = sut
        trackForMemoryLeaks(presenter, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, presenter)
    }

    
    private func makeWeather(location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 1.23, longitude: 2.34),
                          cityName: String = "madrid",
                          temperature: Double = 12.5,
                          description: String = "sunny",
                             iconName: String = "sunny") -> (model: Weather, viewModel: ViewModel) {
        let weather = Weather(location: location,
                           cityName: cityName,
                           temperature: temperature,
                           description: description,
                           iconName: iconName)
        let viewModel = ViewModel(latitude: "\(weather.location.latitude)",
                                  longitude: "\(weather.location.longitude)",
                                  cityName: weather.cityName,
                                  temperature: "\(weather.temperature)",
                                  weatherDescription: weather.description,
                                  weatherIcon: weather.iconName)
        
        return (weather, viewModel)
      
    }
    
    private final class PresenterSpy: PresenterProtocol {
        weak var view: ViewProtocol?
        var loadCount = 0
        
        func viewDidLoadAction() {
            loadCount += 1
        }
        
        func reloadAction() {
            loadCount += 1
        }
        
        func completeLoading(with weather: ViewModel) {
            view?.display(weather)
        }
        
        func completeWithError() {
            view?.displayErrorWith(text: "an error Text")
        }
    }
}


extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject,
                             file: StaticString = #filePath,
                             line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,
                         "Instance should have been deallocated. Potential Memory leak",
                         file: file,
                         line: line)
        }
    }
}
