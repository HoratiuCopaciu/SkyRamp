//
//  URL+QueryParameters.swift
//  
//
//  Created by Horatiu Copaciu on 17.02.2022.
//

import Foundation

extension URL {
    func appendingQueryParameters(_ parameters: [String: String]) throws -> Self {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            throw NSError(domain: String(describing: self), code: 0, userInfo: parameters)
        }
        var queryItems = components.queryItems ?? []
        queryItems.append(contentsOf: parameters.map { URLQueryItem(name: $0.0, value: $0.1) })
        components.queryItems = queryItems
        
        guard let result = components.url else {
            throw NSError(domain: String(describing: self), code: 0, userInfo: ["url": absoluteString])
        }
        return result
    }
}
