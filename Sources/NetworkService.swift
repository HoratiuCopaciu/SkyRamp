//
//  NetworkService.swift
//  
//
//  Created by Horatiu Copaciu on 29.10.2021.
//

import Foundation

public protocol URLRequestConvertible {
    func asURLRequest() throws -> URLRequest
}

public protocol NetworkServiceProtocol {
    func execute(request: URLRequest,
                 with completion: @escaping (Data?, URLResponse?, Error?) -> Void)
    func execute<Response>(handler: WebHandler<Response>,
                           with completion: @escaping (Result<Response, Error>) -> Void)
}

public final class NetworkService {
    private let networkTaskProvider: NetworkTaskProviderProtocol
    private let dispatchQueue: DispatchQueueProtocol
    
    public init(networkTaskProvider: NetworkTaskProviderProtocol,
                dispatchQueue: DispatchQueueProtocol = DispatchQueue.main) {
        self.networkTaskProvider = networkTaskProvider
        self.dispatchQueue = dispatchQueue
    }
}

extension NetworkService: NetworkServiceProtocol {
    public func execute(request: URLRequest,
                        with completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        execute(request: request, dispatchQueue: dispatchQueue, with: completion)
    }
    
    public func execute<Response>(handler: WebHandler<Response>,
                                  with completion: @escaping (Result<Response, Error>) -> Void) {
        do {
            try execute(handler: handler, dispatchQueue: dispatchQueue, with: completion)
        } catch {
            dispatchQueue.async {
                completion(.failure(error))
            }
        }
    }
}

private extension NetworkService {
    func execute<Response>(handler: WebHandler<Response>,
                           dispatchQueue: DispatchQueueProtocol,
                           with completion: @escaping (Result<Response, Error>) -> Void) throws {
        let request = try handler.asURLRequest()
        networkTaskProvider
            .networkDataTask(with: request,
                             completion: { data, response, error in
                let result = handler.handle(data, response, error)
                dispatchQueue.async {
                    completion(result)
                }
            })
            .resume()
    }
    
    func execute(request: URLRequest,
                 dispatchQueue: DispatchQueueProtocol,
                 with completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        networkTaskProvider
            .networkDataTask(with: request,
                             completion: { data, response, error in
                dispatchQueue.async {
                    completion(data, response, error)
                }
            })
            .resume()
    }
}
