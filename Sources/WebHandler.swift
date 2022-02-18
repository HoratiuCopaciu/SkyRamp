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

open class WebHandler<Response> {
    private let baseURL: URL
    private let urlPaths: [String]
    private let httpMethod: HttpMethod
    private let httpHeaders: [String: String]?
    private let queryParameters: [String: String]?
    private let statusCodeValidator: (Int) -> Bool
    private let parameterSerializer: WebHandlerParameterSerializer?
    private let responseDeserializer: WebHandlerResponseDeserializer<Response>
    private let errorDeserializer: WebHandlerErrorDeserializer?
    
    public init(baseURL: URL,
                httpMethod: HttpMethod,
                urlPaths: [String],
                httpHeaders: [String: String]?,
                queryParameters: [String: String]?,
                expectedStatusCode: Int,
                parameterSerializer: WebHandlerParameterSerializer?,
                responseDeserializer: WebHandlerResponseDeserializer<Response>,
                errorDeserializer: WebHandlerErrorDeserializer?) {
        self.baseURL = baseURL
        self.httpMethod = httpMethod
        self.urlPaths = urlPaths
        self.httpHeaders = httpHeaders
        self.queryParameters = queryParameters
        self.statusCodeValidator = { $0 == expectedStatusCode }
        self.parameterSerializer = parameterSerializer
        self.responseDeserializer = responseDeserializer
        self.errorDeserializer = errorDeserializer
    }
    
    open func handle(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<Response, Error> {
        let result: Result<Response, Error>
        
        if let httpResponse = response as? HTTPURLResponse,
           validate(statusCode: httpResponse.statusCode) {
            do {
                let value = try deserialize(httpResponse.statusCode, data)
                result = .success(value)
            } catch {
                let deserializedError = deserializeError(httpResponse.statusCode, data, error)
                result = .failure(deserializedError ?? error)
            }
        } else {
            let error = error ?? NSError(domain: String(describing: self), code: 0, userInfo: nil)
            result = .failure(error)
        }

        return result
    }
}

extension WebHandler: URLRequestConvertible {
    private enum HttpHeaderFields: String {
        case accept = "Accept"
        case contentType = "Content-Type"
    }
    
    public func asURLRequest() throws -> URLRequest {
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
    func deserialize(_ statusCode: Int, _ data: Data?) throws -> Response {
        try responseDeserializer.deserialize(statusCode, data)
    }
    
    func deserializeError(_ statusCode: Int, _ data: Data?, _ error: Error?) -> Error? {
        errorDeserializer?.deserialize(statusCode, data, error)
    }
    
    func validate(statusCode: Int) -> Bool {
        statusCodeValidator(statusCode)
    }
}
