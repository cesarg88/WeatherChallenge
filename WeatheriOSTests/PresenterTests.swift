//
//  PresenterTests.swift
//  WeatheriOSTests
//
//  Created by César González on 28/12/21.
//

import XCTest
import WeatheriOS
import WeatherChallenge
import CoreLocation

class PresenterTests: XCTestCase {
    
    
    func test_presenter_shouldNotAskForWeatherDataUponCreation() {
        let (_, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0)
    }
    
    func test_viewDidLoad_shouldLoadWeatherFromClient() {
        let (sut, loader) = makeSUT()
        sut.viewDidLoadAction()
        XCTAssertEqual(loader.loadFeedCallCount, 1)
    }
    
    func test_viewDidLoad_shouldLoadWeatherFromClientWithCorrectLocationType() {
        let (sut, loader) = makeSUT()
        sut.viewDidLoadAction()
        XCTAssertTrue(loader.locationType == .initial)
    }
    
    func test_changeLocation_shouldLoadWeatherFromClientWithCorrectLocationType() {
        let (sut, loader) = makeSUT()
        sut.reloadAction()
        XCTAssertTrue(loader.locationType == .random)
    }
    
    func test_load_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let loader = LoaderSpy()
        var sut: PresenterProtocol? = Presenter(loader: loader)
        
        sut?.viewDidLoadAction()
        let view = ViewSpy()
        sut?.view = view
        
        sut = nil
        let weather = makeWeather()
        loader.completeWeatherLoading(with: weather.model)
        XCTAssertTrue(view.capturedResult.isEmpty)
    }
    
    func test_load_whenFailureResponse_shouldAskViewToDisplayError() {
        var (sut, loader) = makeSUT()
        let view = ViewSpy()
        sut.view = view
        sut.viewDidLoadAction()
        
        loader.completeFeedLoadingWithError()
        XCTAssertNotNil(view.error)
    }
    
    
    func test_load_whenSuccessResponse_shouldSetViewModel() {
        var (sut, loader) = makeSUT()
        let view = ViewSpy()
        sut.view = view
        sut.viewDidLoadAction()
        let weather = makeWeather()
        loader.completeWeatherLoading(with: weather.model)
        let viewModel = view.capturedResult.first!
        XCTAssertNotNil(viewModel)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: PresenterProtocol, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = Presenter(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
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
    
    private final class LoaderSpy: WeatherLoader {
        
        private var weatherRequests: [(WeatherLoader.Result) -> Void] = []
        
        var loadFeedCallCount: Int {
            return weatherRequests.count
        }
        
        var locationType: LocationType?
        
        
        func loadWeatherFor(locationType: LocationType, completion: @escaping (WeatherLoader.Result) -> Void) {
            self.locationType = locationType
            weatherRequests.append(completion)
        }
        
        func completeWeatherLoading(with weather: Weather, at index: Int = 0) {
            weatherRequests[index](.success(weather))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            weatherRequests[index](.failure(error))
        }
    }
    
    private final class ViewSpy: ViewProtocol {
        
        var error: String?
        var capturedResult: [ViewModel] = []
        
        func display(_ viewModel: ViewModel) {
            capturedResult.append(viewModel)
        }
        
        func displayErrorWith(text: String) {
            error = text
        }
    }
    
}

