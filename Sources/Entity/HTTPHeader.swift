//
//  HTTPHeader.swift
//  Network
//
//  Created by Horatiu Copaciu on 29/08/2019.
//  Copyright © 2019 Horatiu Copaciu. All rights reserved.
//

import Foundation

public struct HTTPHeader: Hashable {
    let name: String
    let value: String
    
    init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

public extension HTTPHeader {
    
    static func authorization(password: String) -> HTTPHeader {
        return authorization(userName: "", password: password)
    }
    
    static func authorization(userName: String, password: String) -> HTTPHeader {
        let credentials = Data("\(userName):\(password)".utf8).base64EncodedString()
        return HTTPHeader.authorization("Basic \(credentials)")
    }
    
    static func authorization(token: String) -> HTTPHeader {
        return HTTPHeader.authorization("Bearer \(token)")
    }
    
    static func authorization(_ value: String) -> HTTPHeader {
        return HTTPHeader(name: "Authorization", value: value)
    }
}

public extension HTTPHeader {
    
    enum ContentType {
        case none
        case json
        case formEncoded
    }
    
    static func contentType(_ contentType: ContentType) -> [HTTPHeader] {
        switch contentType {
        case .none:
            return []
        case .json:
            return [HTTPHeader(name: "Content-Type", value: "application/json"),
                    HTTPHeader(name: "Accept", value: "application/json")]
        case .formEncoded:
            return [HTTPHeader(name: "Content-Type", value: "application/x-www-form-urlencoded"),
                    HTTPHeader(name: "Accept", value: "application/json")]
        }
    }
    
    static func acceptLanguage(_ language: String) -> HTTPHeader {
        return HTTPHeader(name: "Accept-Language", value: language)
    }
}
