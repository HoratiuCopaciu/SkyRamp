//
//  NetworkTaskProvider.swift
//  
//
//  Created by Horatiu Copaciu on 17.02.2022.
//

import Foundation
import Combine

/// @mockable
public protocol NetworkTaskProviderProtocol {
    @discardableResult
    func networkDataTask(with request: URLRequest,
                         completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkTask
    @discardableResult
    func publisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: NetworkTaskProviderProtocol {
    public func networkDataTask(with request: URLRequest,
                                completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkTask {
        dataTask(with: request, completionHandler: completion)
    }
    
    public func publisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
}
