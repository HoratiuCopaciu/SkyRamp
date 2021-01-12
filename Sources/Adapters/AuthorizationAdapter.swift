//
//  AuthorizationAdapter.swift
//
//  Created by Horatiu Copaciu on 16/09/2019.
//  Copyright © 2019 Horatiu Copaciu. All rights reserved.
//

import Foundation

struct AuthorizationAdapter: RequestAdapter {
    
    private let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    func adapt(_ request: URLRequest) throws -> URLRequest {
        var request = request
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }
}
