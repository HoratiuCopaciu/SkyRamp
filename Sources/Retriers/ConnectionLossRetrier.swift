//
//  ConnectionLossRetrier.swift
//
//  Created by Horatiu Copaciu on 29/10/2019.
//  Copyright © 2019 Horatiu Copaciu. All rights reserved.
//

import Foundation

class ConnectionLossRetrier: RequestRetrier {
    
    func shouldRetry(_ session: URLSession, request: URLRequest, for error: Error, completion: @escaping (Bool) -> Void) {
        if let networkError = error as NSError?,
            networkError.isNetworkConnectionError() || networkError.isNetworkTimeOutError() {
            completion(true)
        } else {
            completion(false)
        }
    }
}

private extension NSError {
    func isNetworkConnectionError() -> Bool {
        guard self.domain == NSURLErrorDomain else {
            return false
        }
        
        if self.code == NSURLErrorNetworkConnectionLost || self.code == NSURLErrorNotConnectedToInternet {
            return true
        }
        return false
    }
}

private extension NSError {
    func isNetworkTimeOutError() -> Bool {
        if self.domain == NSURLErrorDomain && self.code == NSURLErrorTimedOut {
            return true
        }
        return false
    }
}
