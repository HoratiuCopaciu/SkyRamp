//
//  NetworkClientProtocolMock.swift
//  
//
//  Created by Horatiu Copaciu on 17.02.2022.
//

import Foundation
import SkyRamp

public final class NetworkClientProtocolMock: NetworkClientProtocol {
    public init() { }
    
    public private(set) var executeCallCount = 0
    public var executeHandler: ((URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> ())?
    public func execute(request: URLRequest, with completion: @escaping (Data?, URLResponse?, Error?) -> Void)  {
        executeCallCount += 1
        if let executeHandler = executeHandler {
            executeHandler(request, completion)
        }
    }
    
    public private(set) var executeHandlerCallCount = 0
    public var executeHandlerHandler: ((Any, Any) -> ())?
    public func execute<Response>(handler: WebHandler<Response>, with completion: @escaping (Result<Response, Error>) -> Void) {
        executeHandlerCallCount += 1
        if let executeHandlerHandler = executeHandlerHandler {
            executeHandlerHandler(handler, completion)
        }
    }
}
