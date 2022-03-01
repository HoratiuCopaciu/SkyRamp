//
//  NetworkService.swift
//  
//
//  Created by Horatiu Copaciu on 29.10.2021.
//

import Foundation
import Combine

public protocol URLRequestConvertible {
    func asURLRequest(baseURL: URL) throws -> URLRequest
}

/// @mockable
public protocol NetworkServiceProtocol {
    func execute(request: URLRequest,
                 with completion: @escaping (Data?, URLResponse?, Error?) -> Void)
        
    func execute<Response>(handler: WebHandler<Response>,
                           with completion: @escaping (Result<Response, Error>) -> Void)
    
    func execute(request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), Error>

    func execute<Response>(handler: WebHandler<Response>) -> AnyPublisher<Response, Error>
}

public final class NetworkService {
    private let baseURL: URL
    private let networkTaskProvider: NetworkTaskProviderProtocol
    private let dispatchQueue: DispatchQueueProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    public init(baseURL: URL,
                networkTaskProvider: NetworkTaskProviderProtocol,
                dispatchQueue: DispatchQueueProtocol = DispatchQueue.main) {
        self.baseURL = baseURL
        self.networkTaskProvider = networkTaskProvider
        self.dispatchQueue = dispatchQueue
    }
}

extension NetworkService: NetworkServiceProtocol {
    public func execute(request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        networkTaskProvider
            .publisher(for: request)
            .mapError({ $0 as Error })
            .eraseToAnyPublisher()
            .receive(on: dispatchQueue)
        
    }
    
    public func execute(request: URLRequest,
                        with completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        execute(request: request)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    completion(nil, nil, error)
                }
            }, receiveValue: { data, response in
                completion(data, response, nil)
            })
            .store(in: &cancellables)
    }

    public func execute<Response>(handler: WebHandler<Response>) -> AnyPublisher<Response, Error> {
        do {
            let request = try handler.asURLRequest(baseURL: baseURL)
            return networkTaskProvider
                .publisher(for: request)
                .tryMap({ data, response in
                    let result = handler.handle(data, response, nil)
                    switch result {
                    case .success(let value):
                        return value
                    case .failure(let error):
                        throw error
                    }
                })
                .eraseToAnyPublisher()
                .receive(on: dispatchQueue)
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
                .receive(on: dispatchQueue)
        }
    }
        
    public func execute<Response>(handler: WebHandler<Response>,
                                  with completion: @escaping (Result<Response, Error>) -> Void) {
        execute(handler: handler)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            }, receiveValue: { response in
                completion(.success(response))
            })
            .store(in: &cancellables)
    }
}
