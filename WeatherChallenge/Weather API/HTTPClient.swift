//
//  HTTPClient.swift
//  WeatherChallenge
//
//  Created by César González on 27/12/21.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void)
}
