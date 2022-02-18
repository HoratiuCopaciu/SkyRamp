//
//  WebHandlerParameterSerializer.swift
//  
//
//  Created by Horatiu Copaciu on 30.10.2021.
//

import Foundation

public struct WebHandlerParameterSerializer {
    public enum ContentType: String {
        case json = "application/json"
        case xml = "application/xml"
        case urlEncoded = "application/x-www-form-urlencoded"
    }
    
    public let contentType: ContentType?
    public let serialize: () throws -> Data?
    
    public init(contentType: ContentType?,
                serialize: @escaping () throws -> Data?) {
        self.contentType = contentType
        self.serialize = serialize
    }
    
    static func json<Body: Encodable>(body: Body, encoder: JSONEncoder = JSONEncoder()) -> Self {
        .init(contentType: .json, serialize: {
            try encoder.encode(body)
        })
    }
    
    public static func xml(serialize: @escaping () throws -> Data?) -> Self {
        .init(contentType: .xml, serialize: serialize)
    }

    public static func urlEncoded(serialize: @escaping () throws -> Data?) -> Self {
        .init(contentType: .urlEncoded, serialize: serialize)
    }
    
    public static let empty: Self = .init(contentType: nil, serialize: { nil })
}
