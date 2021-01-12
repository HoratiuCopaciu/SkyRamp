//
//  RequestMock.swift
//
//  Created by Horatiu Copaciu on 05/05/2020.
//  Copyright © 2020 Horatiu Copaciu. All rights reserved.
//

import Foundation

final class RequestMock: URLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        return hasResponse(for: request)
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let response = RequestMock.response(for: request) else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + response.delay) { [weak self] in
            guard let self = self else { return }
            self.client?.urlProtocol(self, didReceive: response.httpResponse, cacheStoragePolicy: .notAllowed)
            
            switch response.result {
            case .success(let data):
                self.client?.urlProtocol(self, didLoad: data)
            case .failure(let error):
                self.client?.urlProtocol(self, didFailWithError: error)
            }
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() {
        
    }
}

extension RequestMock {
    static private var responses: [ResponseMock] = []
    
    static func add(response: ResponseMock) {
        responses.append(response)
    }
    
    static func removeAll() {
        responses.removeAll()
    }
    
    static func response(for request: URLRequest) -> ResponseMock? {
        return responses.first(where: {
            $0.url.absoluteString == request.url?.absoluteString
        })
    }
    
    static func hasResponse(for request: URLRequest) -> Bool {
        return response(for: request) != nil
    }
}
