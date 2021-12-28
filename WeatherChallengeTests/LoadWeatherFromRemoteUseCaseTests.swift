//
//  LoadWeatherFromRemoteUseCaseTests.swift
//  WeatherChallengeTests
//
//  Created by César González on 27/12/21.
//

import XCTest
import WeatherChallenge
import CoreLocation

class LoadWeatherFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_createsCorrectURL() {
        let (sut, client) = makeSUT()
        sut.loadWeatherFor(locationType: .initial) { _ in }
        XCTAssertEqual(client.requestedURLs, [correctURL])
    }
    
    func test_loadTwice_requestDataFromURL() {
        let (sut, client) = makeSUT()
        sut.loadWeatherFor(locationType: .initial) { _ in }
        sut.loadWeatherFor(locationType: .initial) { _ in }
        XCTAssertEqual(client.requestedURLs, [correctURL, correctURL])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut,
               toCompleteWith: failure(.connectivity),
               when: {
                let clientError = NSError(domain: "test", code: 0, userInfo: nil)
                client.complete(with: clientError)
               })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut,
                   toCompleteWith: failure(.invalidData),
                   when: {
                let json = makeWeatherJSON(item: makeItem().json)
                    client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        let item = makeItem()
     
        expect(sut,
               toCompleteWith: .success(item.model),
               when: {
            let json =  makeWeatherJSON(item: item.json)
                client.complete(withStatusCode: 200, data: json)
               })
    }
    
    func test_load_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: WeatherLoader? = RemoteWeatherLoader(client: client)
        
        var capturedResults: [WeatherLoader.Result] = []
        sut?.loadWeatherFor(locationType: .initial) { capturedResults.append($0) }
        
        sut = nil
        let json = makeWeatherJSON(item: makeItem().json)
        client.complete(withStatusCode: 200, data: json)
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: WeatherLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteWeatherLoader(client: client)
        trackForMemoryLeaks(sut,file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut: sut,
                client: client)
    }
    
    //file and line params are used to report the error on the correct line
    private func expect(_ sut: WeatherLoader,
                        toCompleteWith expectedResult: WeatherLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.loadWeatherFor(locationType: .initial) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteWeatherLoader.Error), .failure(expectedError as RemoteWeatherLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result")
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure( _ error: RemoteWeatherLoader.Error) -> WeatherLoader.Result {
        return .failure(error)
    }
    
    private func makeWeatherJSON(item: [String: Any]) -> Data {

        let json = try! JSONSerialization.data(withJSONObject: item)
        return json
    }
    
    private func makeItem(location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 1.23, longitude: 2.34),
                          cityName: String = "madrid",
                          temperature: Double = 0.0,
                          description: String = "sunny",
                          iconName: String = "sunny") -> (model: Weather, json: [String: Any]) {
        let item = Weather(location: location,
                           cityName: cityName,
                           temperature: temperature,
                           description: description,
                           iconName: iconName)
        
        let json = ["coord":["lon": item.location.longitude,
                             "lat": item.location.latitude],
                        "weather": [["id":807,
                                     "main":item.description,
                                     "description":item.description,
                                     "icon":item.iconName]],
                        "main": ["temp": item.temperature],
                        "name": item.cityName
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private var anyLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 40.416775, longitude: -3.70379)
    }
    
    private var correctURL: URL {
        URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(anyLocation.latitude)&lon=\(anyLocation.longitude)&appid=b4ccaaeb72655067d09d3c0da0a6de92&units=metric&lang=es")!
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int,
                      data: Data,
                      at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success((data, response)))
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
