//
//  NetworkError.swift
//  Network
//
//  Created by Horatiu Copaciu on 28/08/2019.
//  Copyright © 2019 Horatiu Copaciu. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case client(status: HttpStatusCode, data: Data?)
    case server(status: HttpStatusCode, data: Data?)
    case domain(error: Error)
    case connection(error: Error)
}

extension NetworkError {
    
    static let invalidURL: NetworkError = {
        let error = NSError(domain: "NetworkError_invalidURL", code: 0, userInfo: nil)
        return .domain(error: error)
    }()
    static let invalidBody: NetworkError = {
        let error = NSError(domain: "NetworkError_invalidBody", code: 0, userInfo: nil)
        return .domain(error: error)
    }()
    static let invalidRequest: NetworkError = {
        let error = NSError(domain: "NetworkError_invalidRequest", code: 0, userInfo: nil)
        return .domain(error: error)
    }()
    static let invalidJson: NetworkError = {
        let error = NSError(domain: "NetworkError_invalidJSON", code: 0, userInfo: nil)
        return .domain(error: error)
    }()
    static let invalidResponse: NetworkError = {
        let error = NSError(domain: "NetworkError_invalidResponse", code: 0, userInfo: nil)
        return .domain(error: error)
    }()
    
    init(response: URLResponse?, data: Data?, error: Error?) {
        if let error = error,
            let nserror = error as NSError?,
            nserror.isNetworkTimeOutError || nserror.isNetworkConnectionError {
            self = .connection(error: error)
        } else {
            if let status = response?.networkStatus {
                switch status {
                case .client:
                    self = .client(status: status, data: data)
                case .server:
                    self = .server(status: status, data: data)
                default:
                    if let error = error {
                        self = .domain(error: error)
                    } else {
                        self = .invalidResponse
                    }
                }
            } else {
                if let error = error {
                    self = .domain(error: error)
                } else {
                    self = .invalidResponse
                }
            }
        }
    }

    func getJSON<Value>() throws -> Value {
        switch self {
        case .client(status: _, data: let data), .server(status: _, data: let data):
            guard let data = data,
                let json: Value = try? JSONSerialization.jsonObject(with: data, options: []) as? Value else {
                throw NetworkError.invalidJson
            }
            return json
        default:
            throw NetworkError.invalidResponse
        }
    }
}

private extension NSError {
    var isNetworkConnectionError: Bool {
        if self.domain == NSURLErrorDomain && self.code == NSURLErrorNetworkConnectionLost || self.code == NSURLErrorNotConnectedToInternet {
            return true
        }
        return false
    }
    var isNetworkTimeOutError: Bool {
        if self.domain == NSURLErrorDomain && self.code == NSURLErrorTimedOut {
            return true
        }
        return false
    }
}
