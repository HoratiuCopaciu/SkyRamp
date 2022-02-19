//
//  WebHandler+URLRequestConvertible.swift
//  
//
//  Created by Horatiu Copaciu on 16.02.2022.
//

import Foundation

public extension WebHandler {
    static func get(
        configuration: WebHandlerConfigurable,
        expectedStatusCode: Int = 200,
        responseDeserializer: WebHandlerResponseDeserializer<Response>,
        errorDeserializer: WebHandlerErrorDeserializer? = nil
    ) -> WebHandler<Response> {
        .init(configuration: configuration,
              httpMethod: .get,
              expectedStatusCode: expectedStatusCode,
              parameterSerializer: .empty,
              responseDeserializer: responseDeserializer,
              errorDeserializer: errorDeserializer)
    }
    
    static func postJSON<Parameters: Encodable>(
        configuration: WebHandlerConfigurable,
        parameters: Parameters,
        expectedStatusCode: Int = 200,
        responseDeserializer: WebHandlerResponseDeserializer<Response>,
        errorDeserializer: WebHandlerErrorDeserializer? = nil
    ) -> WebHandler<Response> {
        .init(configuration: configuration,
              httpMethod: .post,
              expectedStatusCode: expectedStatusCode,
              parameterSerializer: .json(body: parameters),
              responseDeserializer: responseDeserializer,
              errorDeserializer: errorDeserializer)
    }
    
    static func putJSON<Parameters: Encodable>(
        configuration: WebHandlerConfigurable,
        parameters: Parameters,
        expectedStatusCode: Int = 200,
        responseDeserializer: WebHandlerResponseDeserializer<Response>,
        errorDeserializer: WebHandlerErrorDeserializer? = nil
    ) -> WebHandler<Response> {
        .init(configuration: configuration,
              httpMethod: .put,
              expectedStatusCode: expectedStatusCode,
              parameterSerializer: .json(body: parameters),
              responseDeserializer: responseDeserializer,
              errorDeserializer: errorDeserializer)
    }
    
    static func patchJSON<Parameters: Encodable>(
        configuration: WebHandlerConfigurable,
        parameters: Parameters,
        expectedStatusCode: Int = 200,
        responseDeserializer: WebHandlerResponseDeserializer<Response>,
        errorDeserializer: WebHandlerErrorDeserializer? = nil
    ) -> WebHandler<Response> {
        .init(configuration: configuration,
              httpMethod: .patch,
              expectedStatusCode: expectedStatusCode,
              parameterSerializer: .json(body: parameters),
              responseDeserializer: responseDeserializer,
              errorDeserializer: errorDeserializer)
    }
    
    static func delete(
        configuration: WebHandlerConfigurable,
        expectedStatusCode: Int = 200,
        responseDeserializer: WebHandlerResponseDeserializer<Response>,
        errorDeserializer: WebHandlerErrorDeserializer? = nil
    ) -> WebHandler<Response> {
        .init(configuration: configuration,
              httpMethod: .delete,
              expectedStatusCode: expectedStatusCode,
              parameterSerializer: .empty,
              responseDeserializer: responseDeserializer,
              errorDeserializer: errorDeserializer)
    }
}
