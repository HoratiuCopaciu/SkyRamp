//
//  NetworkingService.swift
//
//  Created by Horatiu Copaciu on 04/11/2019.
//  Copyright © 2019 Horatiu Copaciu. All rights reserved.
//

import Foundation

protocol NetworkingService {
    var baseURL: URL { get }
    var session: URLSession { get }
    var adapter: RequestAdapter? { get }
    var retrier: RequestRetrier? { get }
    var backgroundTaskType: BackgroundTask.Type? { get }
}

extension NetworkingService {
    func execute<Output>(_ request: RequestConvertible, transform: @escaping (NetworkResponse<Data>) throws -> Output, completion: @escaping (NetworkResponse<Output>) -> Void) {
        
        self.execute(request) { response in
            do {
                let output: Output = try transform(response)
                DispatchQueue.main.async {
                    completion(.success(output))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.domain(error: error)))
                }
            }
        }
    }
    
    func execute<Output>(_ request: RequestConvertible, expecting output: Output.Type, completion: @escaping (NetworkResponse<Output>) -> Void) where Output: Decodable {
        execute(request) { response in
            switch response {
            case .success:
                do {
                    let output: Output = try response.decodeJSON()
                    completion(.success(output))
                } catch {
                    completion(.failure(.invalidJson))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func execute(_ request: RequestConvertible, completion: @escaping (NetworkResponse<Data>) -> Void) {
        guard let urlRequest = try? adapt(request) else {
            completion(.failure(.invalidRequest))
            return
        }
        
        let backgroundTask = backgroundTaskType?.executeTask()
        session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                self.shouldRetry(self.session, request: urlRequest, for: error) { shouldRetry in
                    if shouldRetry {
                        self.execute(request, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            backgroundTask?.end()
                            completion(.failure(.connection(error: error)))
                        }
                    }
                }
            } else {
                let response = self.networkResponse(from: data, response: response)                
                DispatchQueue.main.async {
                    backgroundTask?.end()
                    completion(response)
                }
            }
        }.resume()
    }
    
    private func adapt(_ request: RequestConvertible) throws -> URLRequest {
        let urlRequest = try request.asURLRequest(url: baseURL)
        guard let adapter = adapter else {
            return urlRequest
        }
        return try adapter.adapt(urlRequest)
    }
    
    private func shouldRetry(_ session: URLSession, request: URLRequest, for error: Error, completion: @escaping (Bool) -> Void) {
        guard let retrier = retrier else {
            completion(false)
            return
        }
        retrier.shouldRetry(session, request: request, for: error, completion: completion)
    }
    
    private func networkResponse(from data: Data?, response: URLResponse?) -> NetworkResponse<Data> {
        guard let status = response?.networkStatus else {
            return .failure(.invalidResponse)
        }
        
        if status == .ok, let data = data {
            return .success(payload)
        }
        
        switch status {
        case .client:
            return .failure(.client(status: status, data: data))
        case .server:
            return .failure(.server(status: status, data: data))
        default:
            return .failure(.invalidResponse)
        }
    }
}

private extension URLResponse {
    var networkStatus: HttpStatusCode? {
        guard let httpResponse = self as? HTTPURLResponse else { return nil }
        return HttpStatusCode(rawValue: httpResponse.statusCode)
    }
}
