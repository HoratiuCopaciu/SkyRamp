//
//  WebHandler+URLRequestConvertible.swift
//  
//
//  Created by Horatiu Copaciu on 16.02.2022.
//

import Foundation

public extension WebHandler {
    static func get(
        baseURL: URL,
        urlPaths: [String] = [],
        httpHeaders: [String: String]? = nil,
        queryParameters: [String: String]? = nil,
        expectedStatusCode: Int = 200,
        responseDeserializer: WebHandlerResponseDeserializer<Response>,
        errorDeserializer: WebHandlerErrorDeserializer? = nil
    ) -> WebHandler<Response> {
        .init(baseURL: baseURL,
              httpMethod: .get,
              urlPaths: urlPaths,
              httpHeaders: httpHeaders,
              queryParameters: queryParameters,
              expectedStatusCode: expectedStatusCode,
              parameterSerializer: .empty,
              responseDeserializer: responseDeserializer,
              errorDeserializer: errorDeserializer)
    }
    
    static func postJSON<Parameters: Encodable>(
        baseURL: URL,
        urlPaths: [String] = [],
        httpHeaders: [String: String]? = nil,
        queryParameters: [String: String]? = nil,
        parameters: Parameters,
        expectedStatusCode: Int = 200,
        responseDeserializer: WebHandlerResponseDeserializer<Response>,
        errorDeserializer: WebHandlerErrorDeserializer? = nil
    ) -> WebHandler<Response> {
        .init(baseURL: baseURL,
              httpMethod: .post,
              urlPaths: urlPaths,
              httpHeaders: httpHeaders,
              queryParameters: queryParameters,
              expectedStatusCode: expectedStatusCode,
              parameterSerializer: .json(body: parameters),
              responseDeserializer: responseDeserializer,
              errorDeserializer: errorDeserializer)
    }
    
    static func putJSON<Parameters: Encodable>(
        baseURL: URL,
        urlPaths: [String] = [],
        httpHeaders: [String: String]? = nil,
        queryParameters: [String: String]? = nil,
        parameters: Parameters,
        expectedStatusCode: Int = 200,
        responseDeserializer: WebHandlerResponseDeserializer<Response>,
        errorDeserializer: WebHandlerErrorDeserializer? = nil
    ) -> WebHandler<Response> {
        .init(baseURL: baseURL,
              httpMethod: .put,
              urlPaths: urlPaths,
              httpHeaders: httpHeaders,
              queryParameters: queryParameters,
              expectedStatusCode: expectedStatusCode,
              parameterSerializer: .json(body: parameters),
              responseDeserializer: responseDeserializer,
              errorDeserializer: errorDeserializer)
    }
    
    static func patchJSON<Parameters: Encodable>(
        baseURL: URL,
        urlPaths: [String] = [],
        httpHeaders: [String: String]? = nil,
        queryParameters: [String: String]? = nil,
        parameters: Parameters,
        expectedStatusCode: Int = 200,
        responseDeserializer: WebHandlerResponseDeserializer<Response>,
        errorDeserializer: WebHandlerErrorDeserializer? = nil
    ) -> WebHandler<Response> {
        .init(baseURL: baseURL,
              httpMethod: .patch,
              urlPaths: urlPaths,
              httpHeaders: httpHeaders,
              queryParameters: queryParameters,
              expectedStatusCode: expectedStatusCode,
              parameterSerializer: .json(body: parameters),
              responseDeserializer: responseDeserializer,
              errorDeserializer: errorDeserializer)
    }
    
    static func delete(
        baseURL: URL,
        urlPaths: [String] = [],
        httpHeaders: [String: String]? = nil,
        queryParameters: [String: String]? = nil,
        expectedStatusCode: Int = 200,
        responseDeserializer: WebHandlerResponseDeserializer<Response>,
        errorDeserializer: WebHandlerErrorDeserializer? = nil
    ) -> WebHandler<Response> {
        .init(baseURL: baseURL,
              httpMethod: .delete,
              urlPaths: urlPaths,
              httpHeaders: httpHeaders,
              queryParameters: queryParameters,
              expectedStatusCode: expectedStatusCode,
              parameterSerializer: .empty,
              responseDeserializer: responseDeserializer,
              errorDeserializer: errorDeserializer)
    }
}
