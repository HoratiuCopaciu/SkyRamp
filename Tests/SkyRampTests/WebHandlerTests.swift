//
//  WebHandlerTests.swift
//  
//
//  Created by Horatiu Copaciu on 18.02.2022.
//

import XCTest
import SkyRamp
import SkyRampMocks

final class WebHandlerTests: XCTestCase {
    private struct ResponseStub: Decodable, Equatable {
        let stringValue: String
        let intValue: Int
        
        init(stringValue: String = "",
             intValue: Int = 0) {
            self.stringValue = stringValue
            self.intValue = intValue
        }
    }
    
    private var baseURL: URL!
    private var httpMethod: HttpMethod!
    private var urlPaths: [String]!
    private var httpHeaders: [String : String]?
    private var queryParameters: [String : String]?
    private var expectedStatusCode: Int!
    private var parameterSerializer: WebHandlerParameterSerializer?
    private var responseDeserializer: WebHandlerResponseDeserializer<ResponseStub>!
    private var responseDeserializerCallCount = 0
    private var errorDeserializer: WebHandlerErrorDeserializer?
    
    private lazy var handler = WebHandler(baseURL: baseURL,
                                          httpMethod: httpMethod,
                                          urlPaths: urlPaths,
                                          httpHeaders: httpHeaders,
                                          queryParameters: queryParameters,
                                          expectedStatusCode: expectedStatusCode,
                                          parameterSerializer: parameterSerializer,
                                          responseDeserializer: responseDeserializer,
                                          errorDeserializer: errorDeserializer)

    override func setUpWithError() throws {
        baseURL = try XCTUnwrap(.init(string: "https://domain.com"))
        httpMethod = .get
        urlPaths = []
        expectedStatusCode = 200
        responseDeserializer = .init(deserialize: { [weak self] _, _ in
            self?.responseDeserializerCallCount += 1
            return ResponseStub()
        })
    }
    
    func testInvalidStatusCode() throws {
        let response = HTTPURLResponse(url: baseURL,
                                       statusCode: 400,
                                       httpVersion: nil,
                                       headerFields: nil)
        let result = handler.handle(nil, response, nil)
        
        XCTAssertNil(result.value)
        XCTAssertEqual((result.error as NSError?)?.code, 0)
        XCTAssertEqual(responseDeserializerCallCount, 0)
    }
    
    func testDeserializeSuccess() throws {
        let response = HTTPURLResponse(url: baseURL,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)
        let responseData = Data()
        let stub = ResponseStub()
        var responseDeserializerCallCount = 0
        responseDeserializer = .init(deserialize: { statusCode, data in
            responseDeserializerCallCount += 1
            XCTAssertEqual(data, responseData)
            XCTAssertEqual(statusCode, response?.statusCode)
            return stub
        })
        
        let result = handler.handle(responseData, response, nil)

        XCTAssertEqual(result.value, stub)
        XCTAssertNil(result.error)
        XCTAssertEqual(responseDeserializerCallCount, 1)
    }
    
    func testDeserializeFailure() throws {
        let response = HTTPURLResponse(url: baseURL,
                                       statusCode: 200,
                                       httpVersion: nil,
                                       headerFields: nil)
        let mockError = MockError()
        let responseData = Data()
        var responseDeserializerCallCount = 0
        responseDeserializer = .init(deserialize: { statusCode, data in
            responseDeserializerCallCount += 1
            XCTAssertEqual(data, responseData)
            XCTAssertEqual(statusCode, response?.statusCode)
            throw mockError
        })
        errorDeserializer = .init(deserialize: { statusCode, data, error in
            XCTAssertEqual(data, responseData)
            XCTAssertEqual(statusCode, response?.statusCode)
            XCTAssertEqual(error as? MockError, mockError)
            return mockError
        })
        let result = handler.handle(responseData, response, nil)

        XCTAssertNil(result.value)
        XCTAssertEqual(result.error as? MockError, mockError)
        XCTAssertEqual(responseDeserializerCallCount, 1)
    }
    
    func testAsURLRequest() throws {
        urlPaths = ["first", "second"]
        queryParameters = ["key": "value"]
        httpHeaders = ["HeaderKey": "HeaderValue"]
        let bodyData = Data()
        parameterSerializer = .init(contentType: .json, serialize: {
            bodyData
        })

        let request = try handler.asURLRequest()
        
        let contentTypeHeaders = ["Content-Type": "application/json"]
        httpHeaders?.merge(contentTypeHeaders, uniquingKeysWith: { current, _ in current })

        XCTAssertEqual(request.url?.absoluteString, "https://domain.com/first/second?key=value")
        XCTAssertEqual(request.allHTTPHeaderFields, httpHeaders)
        XCTAssertEqual(request.httpBody, bodyData)
    }
}
