//
//  HttpStatusCode.swift
//  Network
//
//  Created by Horatiu Copaciu on 28/08/2019.
//  Copyright © 2019 Horatiu Copaciu. All rights reserved.
//

import Foundation

enum HttpStatusCode: RawRepresentable {
    typealias RawValue = Int
    
    case ok
    case client(Int)
    case server(Int)
    
    var rawValue: Int {
        switch self {
        case .ok:
            return 200
        case .client(let value), .server(let value):
            return value
        }
    }

    var isUnauthorized: Bool {
        guard case .client(let status) = self, status == 401 else { return false }
        return true
    }
    var isForbidden: Bool {
        guard case .client(let status) = self, status == 403 else { return false }
        return true
    }
    
    var isClient: Bool {
        guard case .client = self else { return false }
        return true
    }
    
    var isServer: Bool {
        guard case .server = self else { return false }
        return true
    }
    
    var isSuccessful: Bool {
        guard case .ok = self else { return false }
        return true
    }
    
    init?(rawValue: Int) {
        switch rawValue {
        case 100...199, 201...399:
            return nil
        case 200:
            self = .ok
        case 400...499:
            self = .client(rawValue)
        case 500...599:
            self = .server(rawValue)
        default:
            return nil
        }
    }
}
