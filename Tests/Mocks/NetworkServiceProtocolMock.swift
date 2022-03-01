//
//  NetworkServiceProtocolMock.swift
//  
//
//  Created by Horatiu Copaciu on 17.02.2022.
//

import Foundation
import SkyRamp
import Combine

public final class NetworkServiceProtocolMock: NetworkServiceProtocol {
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
    
    public private(set) var executeRequestCallCount = 0
    public var executeRequestHandler: ((URLRequest) -> (AnyPublisher<(data: Data, response: URLResponse), Error>))?
    public func execute(request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        executeRequestCallCount += 1
        if let executeRequestHandler = executeRequestHandler {
            return executeRequestHandler(request)
        }
        fatalError("executeRequestHandler returns can't have a default value thus its handler must be set")
    }

    public private(set) var executeHandlerResponseCallCount = 0
    public var executeHandlerResponseHandler: ((Any) -> (Any))?
    public func execute<Response>(handler: WebHandler<Response>) -> AnyPublisher<Response, Error> {
        executeHandlerResponseCallCount += 1
        if let executeHandlerResponseHandler = executeHandlerResponseHandler {
            return executeHandlerResponseHandler(handler) as! AnyPublisher<Response, Error>
        }
        fatalError("executeHandlerResponseHandler returns can't have a default value thus its handler must be set")
    }
}
