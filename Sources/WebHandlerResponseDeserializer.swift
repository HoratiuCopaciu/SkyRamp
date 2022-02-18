//
//  WebHandlerResponseDeserializer.swift
//  
//
//  Created by Horatiu Copaciu on 30.10.2021.
//

import Foundation

public struct WebHandlerResponseDeserializer<Response> {
    public let deserialize: (_ statusCode: Int, _ data: Data?) throws -> Response
    
    public init(deserialize: @escaping (Int, Data?) throws -> Response) {
        self.deserialize = deserialize
    }
    
    public static func json(decoder: JSONDecoder) -> Self where Response: Decodable {
        .init(deserialize: { statusCode, data in
            guard let data = data else {
                throw NSError(domain: String(describing: self), code: statusCode, userInfo: nil)
            }
            return try decoder.decode(Response.self, from: data)
        })
    }
}
