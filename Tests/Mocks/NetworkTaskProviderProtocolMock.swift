//
//  NetworkTaskProviderProtocolMock.swift
//  
//
//  Created by Horatiu Copaciu on 17.02.2022.
//

import Foundation
import SkyRamp

public final class NetworkTaskProviderProtocolMock: NetworkTaskProviderProtocol {
    public init() { }

    public private(set) var networkDataTaskCallCount = 0
    public var networkDataTaskHandler: ((URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> (NetworkTask))?
    public func networkDataTask(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkTask {
        networkDataTaskCallCount += 1
        if let networkDataTaskHandler = networkDataTaskHandler {
            return networkDataTaskHandler(request, completion)
        }
        fatalError("networkDataTaskHandler returns can't have a default value thus its handler must be set")
    }
}

