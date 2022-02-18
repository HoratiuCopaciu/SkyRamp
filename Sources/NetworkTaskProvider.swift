//
//  NetworkTaskProvider.swift
//  
//
//  Created by Horatiu Copaciu on 17.02.2022.
//

import Foundation

public protocol NetworkTaskProviderProtocol {
    @discardableResult
    func networkDataTask(with request: URLRequest,
                         completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkTask
}

extension URLSession: NetworkTaskProviderProtocol {
    public func networkDataTask(with request: URLRequest,
                                completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkTask {
        dataTask(with: request, completionHandler: completion)
    }
}
