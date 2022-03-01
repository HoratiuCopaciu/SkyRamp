//
//  WebHandler.swift
//  
//
//  Created by Horatiu Copaciu on 30.10.2021.
//

import Foundation

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public protocol WebHandlerConfigurable {
    var urlPaths: [String] { get }
    var httpHeaders: [String: String]? { get }
    var queryParameters: [String: String]? { get }
}

open class WebHandler<Response> {
    private let urlPaths: [String]
    private let httpMethod: HttpMethod
    private let httpHeaders: [String: String]?
    private let queryParameters: [String: String]?
    private let statusCodeValidator: (Int) -> Bool
    private let parameterSerializer: WebHandlerParameterSerializer?
    private let responseDeserializer: WebHandlerResponseDeserializer<Response>
    private let errorDeserializer: WebHandlerErrorDeserializer?
    
    public init(urlPaths: [String],
                httpHeaders: [String: String]?,
                queryParameters: [String: String]?,
                httpMethod: HttpMethod,
                expectedStatusCode: Int,
                parameterSerializer: WebHandlerParameterSerializer?,
                responseDeserializer: WebHandlerResponseDeserializer<Response>,
                errorDeserializer: WebHandlerErrorDeserializer?) {
        self.urlPaths = urlPaths
        self.httpHeaders = httpHeaders
        self.queryParameters = queryParameters
        self.httpMethod = httpMethod
        self.statusCodeValidator = { $0 == expectedStatusCode }
        self.parameterSerializer = parameterSerializer
        self.responseDeserializer = responseDeserializer
        self.errorDeserializer = errorDeserializer
    }
    
    public convenience init(configuration: WebHandlerConfigurable,
                            httpMethod: HttpMethod,
                            expectedStatusCode: Int,
                            parameterSerializer: WebHandlerParameterSerializer?,
                            responseDeserializer: WebHandlerResponseDeserializer<Response>,
                            errorDeserializer: WebHandlerErrorDeserializer?) {
        self.init(urlPaths: configuration.urlPaths,
                  httpHeaders: configuration.httpHeaders,
                  queryParameters: configuration.queryParameters,
                  httpMethod: httpMethod,
                  expectedStatusCode: expectedStatusCode,
                  parameterSerializer: parameterSerializer,
                  responseDeserializer: responseDeserializer,
                  errorDeserializer: errorDeserializer)
    }
    
    open func handle(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<Response, Error> {
        guard let httpResponse = response as? HTTPURLResponse else {
            let error = error ?? NSError.error(domain: String(describing: self))
            return .failure(error)
        }
        
        let result: Result<Response, Error>
        
        if validate(statusCode: httpResponse.statusCode) {
            result = deserialize(httpResponse.statusCode, data)
        } else {
            if let deserializedError = deserializeError(httpResponse.statusCode, data, error) {
                result = .failure(deserializedError)
            } else {
                let error = error ?? NSError.error(domain: String(describing: self))
                result = .failure(error)
            }
        }
        
        return result
    }
}

extension WebHandler: URLRequestConvertible {
    private enum HttpHeaderFields: String {
        case accept = "Accept"
        case contentType = "Content-Type"
    }
    
    public func asURLRequest(baseURL: URL) throws -> URLRequest {
        var url = baseURL.appendingPathComponent(NSString.path(withComponents: urlPaths))
        
        if let parameters = queryParameters, !parameters.isEmpty {
            url = try url.appendingQueryParameters(parameters)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        httpHeaders?.forEach { (key: String, value: String) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let parameterSerializer = parameterSerializer {
            request.httpBody = try parameterSerializer.serialize()
            
            if let contentType = parameterSerializer.contentType {
                request.setValue(contentType.rawValue,
                                 forHTTPHeaderField: HttpHeaderFields.contentType.rawValue)
            }
        }
        
        return request
    }
}

private extension WebHandler {
    func deserialize(_ statusCode: Int, _ data: Data?) -> Result<Response, Error> {
        let result: Result<Response, Error>
        do {
            let value = try responseDeserializer.deserialize(statusCode, data)
            result = .success(value)
        } catch {
            result = .failure(error)
        }
        return result
    }
    
    func deserializeError(_ statusCode: Int, _ data: Data?, _ error: Error?) -> Error? {
        errorDeserializer?.deserialize(statusCode, data, error)
    }
    
    func validate(statusCode: Int) -> Bool {
        statusCodeValidator(statusCode)
    }
}

private extension NSError {
    static func error(domain: String,
                      code: Int = 0,
                      userInfo: [String: Any]? = nil) -> NSError {
        NSError(domain: domain, code: code, userInfo: userInfo)
    }
}
