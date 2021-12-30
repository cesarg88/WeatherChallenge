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

final class WeatherUIIntegrationTests: XCTestCase {

    func test_viewDidLoad_requestWeatherFromPresenter() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
        sut.simulateButtonAction()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a reload")

        sut.simulateButtonAction()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_viewDidLoad_shouldLoadWeatherFromClientWithCorrectLocationType() {
           let (sut, loader) = makeSUT()
           sut.loadViewIfNeeded()
           XCTAssertTrue(loader.locationType == .initial)
       }
       
       func test_changeLocation_shouldLoadWeatherFromClientWithCorrectLocationType() {
           let (sut, loader) = makeSUT()
           sut.simulateButtonAction()
           XCTAssertTrue(loader.locationType == .random)
       }
    
    func test_loadWeatherCompletion_dispatchesFromBackgroundToMainThread() {
            let (sut, loader) = makeSUT()
            sut.loadViewIfNeeded()

            let exp = expectation(description: "Wait for background queue")
            DispatchQueue.global().async {
                loader.completeWeatherLoading(with: self.weather)
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1.0)
        }
    
    func test_displayViewModel_shouldNotDisplayDataWithNoCityName() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeWeatherLoading(with: noNameWeather)
        loader.completeWeatherLoading(with: weather)
        XCTAssertFalse(sut.cityNameLabel!.text!.isEmpty)
    }
    
    func test_displayViewModel_shouldNotShowErrorViewOnSuccessResponse() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeWeatherLoading(with: weather)
        XCTAssertNil(sut.errorView)
    }
    
    func test_displayError_shouldDisplayErrorViewOnFailureResponse() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeWeatherLoadingWithError()
        XCTAssert(sut.errorView != nil)
    }
    
    func test_changeLocation_shouldHideErrorView() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeWeatherLoading(with: weather)
        sut.simulateButtonAction()
        loader.completeWeatherLoadingWithError()
        sut.simulateButtonAction()
        XCTAssert(sut.errorView == nil)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = UIComposer.composeWith(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private var weather: Weather {
        makeWeather(location: CLLocationCoordinate2D(latitude: 1.23, longitude: 2.34),
                              cityName: "Madrid",
                              temperature: 12.5,
                              description: "sunny",
                              iconName: "sunny")
    }
    
    private var noNameWeather: Weather {
        makeWeather(location: CLLocationCoordinate2D(latitude: 1.23, longitude: 2.34),
                              cityName: "",
                              temperature: 12.5,
                              description: "sunny",
                              iconName: "sunny")
    }

    
    private func makeWeather(location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 1.23, longitude: 2.34),
                          cityName: String = "madrid",
                          temperature: Double = 12.5,
                          description: String = "sunny",
                             iconName: String = "sunny") ->  Weather{
        let weather = Weather(location: location,
                           cityName: cityName,
                           temperature: temperature,
                           description: description,
                           iconName: iconName)
        
        return weather
      
    }
    
    private final class LoaderSpy: WeatherLoader {
        
        private var weatherRequests: [(WeatherLoader.Result) -> Void] = []
        
        var loadCallCount: Int {
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
        
        func completeWeatherLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            weatherRequests[index](.failure(error))
        }
    }

}

private extension ViewController {
    
    func simulateButtonAction() {
        let button = view.subviews.compactMap({ $0 as? UIButton}).first
        button?.sendActions(for: .touchUpInside)
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
