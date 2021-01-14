//
//  ResponseMock.swift
//
//  Created by Horatiu Copaciu on 05/05/2020.
//  Copyright © 2020 Horatiu Copaciu. All rights reserved.
//

import Foundation
import SkyRamp

public struct ResponseMock {
    public let url: URL
    public let httpCode: HttpStatusCode
    public let headers: [HTTPHeader]
    public let result: Result<Data, Error>
    public let delay: TimeInterval
}

public extension ResponseMock {
    var httpResponse: HTTPURLResponse {
        var headerFields: [String: String] = [:]
        headers.forEach { header in
            headerFields[header.name] = header.value
        }
        return HTTPURLResponse(url: url, statusCode: httpCode.rawValue, httpVersion: "HTTP/1.1", headerFields: headerFields)!
    }
    
    init(url: URL = URL.mockURL,
         path: String,
         httpCode: HttpStatusCode = .ok,
         headers: [HTTPHeader] = HTTPHeader.contentType(.json),
         result: Result<Data, Error>,
         delay: TimeInterval = 0.1) {
        self.url = URL(string: path, relativeTo: url)!
        self.httpCode = httpCode
        self.headers = headers
        self.result = result
        self.delay = delay
    }
    
    init(path: String, result: Result<Data, Error>) {
        self.init(path: path, httpCode: .ok, headers: HTTPHeader.contentType(.json), result: result, delay: 0.1)
    }
    
    init(path: String, httpCode: HttpStatusCode, result: Result<Data, Error>) {
        self.init(path: path, httpCode: httpCode, headers: HTTPHeader.contentType(.json), result: result, delay: 0.1)
    }
    
    static func mock(path: String, httpCode: HttpStatusCode) -> ResponseMock {
        return ResponseMock(path: path, httpCode: httpCode, result: .success(Data()))
    }
    
    static func mock<Payload: ExpressibleByDictionaryLiteral>(path: String, httpCode: HttpStatusCode, payload: Payload) -> ResponseMock {
        let data = try? JSONSerialization.data(withJSONObject: payload, options: [])
        switch httpCode {
        case .ok:
            return ResponseMock(path: path, httpCode: httpCode, result: .success(data!))
        case .client:
            return ResponseMock(path: path, httpCode: httpCode, result: .failure(NetworkError.client(status: httpCode, data: data)))
        case .server:
            return ResponseMock(path: path, httpCode: httpCode, result: .failure(NetworkError.server(status: httpCode, data: data)))
        }
    }
}
