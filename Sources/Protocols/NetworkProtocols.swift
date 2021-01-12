//
//  NetworkProtocols.swift
//  Network
//
//  Created by Horatiu Copaciu on 28/08/2019.
//  Copyright © 2019 Horatiu Copaciu. All rights reserved.
//

import Foundation

public protocol RequestAdapter {
    func adapt(_ request: URLRequest) throws -> URLRequest
}

public protocol RequestRetrier {
    func shouldRetry(_ session: URLSession, request: URLRequest, for error: Error, completion: @escaping (Bool) -> Void)
}

public protocol RequestConvertible {
    var path: String { get }
    var method: HttpMethod { get }
    var headers: [HTTPHeader] { get }
    var body: HttpBody? { get }
    func asURLRequest(url: URL) throws -> URLRequest
}

public extension RequestConvertible {
    
    func asURLRequest(url: URL) throws -> URLRequest {
        guard let urlWithPath = URL(string: path, relativeTo: url) else {
            throw NetworkError.invalidURL
        }
                
        var request = URLRequest(url: urlWithPath)
        request.httpMethod = method.rawValue
        request.httpBody = body?.encode()
        
        if !headers.isEmpty {
            headers.forEach({
                request.setValue($0.value, forHTTPHeaderField: $0.name)
            })
        }
        
        return request
    }
}
