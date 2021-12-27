//
//  HTTPClient.swift
//  WeatherChallenge
//
//  Created by César González on 27/12/21.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
