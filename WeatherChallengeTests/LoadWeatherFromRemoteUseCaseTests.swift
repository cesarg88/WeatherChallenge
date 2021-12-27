//
//  LoadWeatherFromRemoteUseCaseTests.swift
//  WeatherChallengeTests
//
//  Created by César González on 27/12/21.
//

import XCTest
import WeatherChallenge

final class WeatherMapper {
    
    public enum Error: Swift.Error {
        case connectivity, invalidData
    }
    
    private struct Root: Decodable {
        let weather: RemoteWeather
    }
    
    private static var OK_200: Int { 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteWeather {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else { throw Error.invalidData }
        return root.weather
    }
}


final class RemoteWeatherLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity, invalidData
    }
  
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (WeatherLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
                case .success((_,_)): break
                case let .failure:
                    completion(.failure(Error.connectivity))
            }
        }
    }
}

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

    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: RemoteWeatherLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteWeatherLoader(url: url, client: client)
        trackForMemoryLeaks(sut,file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut: sut,
                client: client)
    }
    
    //file and line params are used to report the error on the correct line
    private func expect(_ sut: RemoteWeatherLoader,
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
