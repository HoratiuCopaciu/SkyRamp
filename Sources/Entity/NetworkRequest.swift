//
//  NetworkRequest.swift
//  Network
//
//  Created by Horatiu Copaciu on 28/08/2019.
//  Copyright © 2019 Horatiu Copaciu. All rights reserved.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct HttpBody {
    enum Encoder {
        case json
        case percent
    }

    let body: [String: Any]
    let encoder: Encoder
    
    init(body: [String: Any], encoder: Encoder = .json) {
        self.body = body
        self.encoder = encoder
    }
    
    func encode() -> Data? {
        switch encoder {
        case .json:
            return try? JSONSerialization.data(withJSONObject: body, options: [])
        case .percent:
            let string = body.compactMap { (key: String, value: Any) -> String? in
                guard let encodedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                    let encodedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                        return nil
                }
                return "\(encodedKey)=\(encodedValue)"
            }.joined(separator: "&")
            
            return string.data(using: .utf8)
        }
    }
}

struct NetworkRequest: RequestConvertible {
    let url: URL
    let path: String
    let method: HttpMethod
    let headers: [HTTPHeader]
    let body: HttpBody?
    
    init(url: URL, path: String = "", method: HttpMethod = .get, headers: [HTTPHeader] = [], body: HttpBody? = nil) {
        self.url = url
        self.path = path
        self.method = method
        self.headers = headers
        self.body = body
    }
}
