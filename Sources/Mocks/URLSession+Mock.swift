//
//  URLSession+Mock.swift
//
//  Created by Horatiu Copaciu on 05/05/2020.
//  Copyright © 2020 Horatiu Copaciu. All rights reserved.
//
import Foundation

public extension URLSession {
    
    static var mocksSession: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [RequestMock.self]
        configuration.timeoutIntervalForRequest = 1
        configuration.timeoutIntervalForResource = 1
        return URLSession(configuration: configuration)
    }
}

public extension URL {
    static let mockURL = URL(string: "https://test.com")!
}

public class TestNetworkingService: NetworkingService {
    public let baseURL: URL
    public let session: URLSession
    public var adapter: RequestAdapter?
    public var retrier: RequestRetrier?
    public var backgroundTaskType: BackgroundTask.Type?
    
    public init() {
        self.baseURL = URL.mockURL
        self.session = URLSession.mocksSession
        self.adapter = nil
        self.retrier = nil
        self.backgroundTaskType = nil
    }
}
