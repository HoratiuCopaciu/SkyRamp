//
//  URLSession+Mock.swift
//
//  Created by Horatiu Copaciu on 05/05/2020.
//  Copyright © 2020 Horatiu Copaciu. All rights reserved.
//
import Foundation

extension URLSession {
    
    static var mocksSession: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [RequestMock.self]
        configuration.timeoutIntervalForRequest = 1
        configuration.timeoutIntervalForResource = 1
        return URLSession(configuration: configuration)
    }
}

extension URL {
    static let mockURL = URL(string: "https://test.com")!
}

class TestNetworkingService: NetworkingService {
    let baseURL: URL
    let session: URLSession
    var adapter: RequestAdapter?
    var retrier: RequestRetrier?
    var backgroundTaskType: BackgroundTask.Type?
    
    init() {
        self.baseURL = URL.mockURL
        self.session = URLSession.mocksSession
        self.adapter = nil
        self.retrier = nil
        self.backgroundTaskType = nil
    }
}
