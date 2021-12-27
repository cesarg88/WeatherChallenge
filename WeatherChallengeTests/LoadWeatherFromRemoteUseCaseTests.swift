//
//  LoadWeatherFromRemoteUseCaseTests.swift
//  WeatherChallengeTests
//
//  Created by César González on 27/12/21.
//

import XCTest
import WeatherChallenge

class LoadWeatherFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadTwice_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
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
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: WeatherLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteWeatherLoader(url: url, client: client)
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
        
        sut.load { receivedResult in
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
    
    private func makeItem(latitude:Double = 1.23,
                          longitude: Double = 2.34,
                          cityName: String = "madrid",
                          temperature: Double = 0.0,
                          description: String = "cloudly",
                          iconName: String = "1d3") -> (model: Weather, json: [String: Any]) {
        let item = Weather(latitude: latitude,
                           longitude: longitude,
                           cityName: cityName,
                           temperature: temperature,
                           description: description,
                           iconName: iconName)
        
        let json = [
            "weather": ["coord":["lon": item.longitude,
                                 "lat": item.latitude],
                        "weather": [["id":807,
                                     "main":item.description,
                                     "description":item.description,
                                     "icon":item.iconName]],
                        "main": ["temp": item.temperature],
                        "name": item.cityName
                       ]
        ].compactMapValues { $0 }
        
        return (item, json)
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
