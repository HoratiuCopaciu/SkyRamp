//
//  URLRequestConvertibleMock.swift
//  
//
//  Created by Horatiu Copaciu on 17.02.2022.
//

import Foundation
import SkyRamp

public final class URLRequestConvertibleMock: URLRequestConvertible {
    public init() { }

    public private(set) var asURLRequestCallCount = 0
    public var asURLRequestHandler: ((URL) throws -> (URLRequest))?
    public func asURLRequest(baseURL: URL) throws -> URLRequest {
        asURLRequestCallCount += 1
        if let asURLRequestHandler = asURLRequestHandler {
            return try asURLRequestHandler(baseURL)
        }
        fatalError("asURLRequestHandler returns can't have a default value thus its handler must be set")
    }
}
