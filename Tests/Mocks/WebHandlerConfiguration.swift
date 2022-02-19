//
//  File.swift
//  
//
//  Created by Horatiu Copaciu on 19.02.2022.
//

import Foundation
import SkyRamp

public struct WebHandlerConfiguration: WebHandlerConfigurable {
    public let baseURL: URL
    public let urlPaths: [String]
    public let httpHeaders: [String : String]?
    public let queryParameters: [String : String]?
    
    public init(baseURL: URL,
                urlPaths: [String] = [],
                httpHeaders: [String : String]? = nil,
                queryParameters: [String : String]? = nil) {
        self.baseURL = baseURL
        self.urlPaths = urlPaths
        self.httpHeaders = httpHeaders
        self.queryParameters = queryParameters
    }
}
