//
//  WebHandlerErrorDeserializer.swift
//  
//
//  Created by Horatiu Copaciu on 17.02.2022.
//

import Foundation

public struct WebHandlerErrorDeserializer {
    public let deserialize: (_ statusCode: Int, _ data: Data?, _ error: Error?) -> Error?
    
    public init(deserialize: @escaping (_ statusCode: Int,
                                        _ data: Data?,
                                        _ error: Error?) -> Error?) {
        self.deserialize = deserialize
    }
    
    static func decodableError<ErrorResponse: Decodable>(
        deserializer: @escaping (_ statusCode: Int,
                                 _ errorResponse: ErrorResponse?) -> Error?
    ) -> Self {
        .init(deserialize: { statusCode, data, _ in
            let errorResponse = data.flatMap({
                try? JSONDecoder().decode(ErrorResponse.self, from: $0)
            })
            return deserializer(statusCode, errorResponse)
        })
    }
}
