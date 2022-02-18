//
//  File.swift
//  
//
//  Created by Horatiu Copaciu on 30.10.2021.
//

import Foundation

public protocol NetworkTask {
    func resume()
    func cancel()
}

extension URLSessionTask: NetworkTask {}
