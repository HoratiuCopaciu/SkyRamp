//
//  NetworkServiceTests.swift
//  
//
//  Created by Horatiu Copaciu on 17.02.2022.
//

import Foundation
import XCTest
import SkyRamp
import SkyRampMocks

final class NetworkServiceTests: XCTestCase {
    private var networkTaskProvider: NetworkTaskProviderProtocolMock!
    private var dispatchQueue: DispatchQueueProtocolMock!
    private lazy var service = NetworkService(networkTaskProvider: networkTaskProvider,
                                              dispatchQueue: dispatchQueue)
    
    override func setUpWithError() throws {
        networkTaskProvider = .init()
        dispatchQueue = .init()
        dispatchQueue.asyncHandler = { _, _, _, block in
            block()
        }
    }
    
    func testExecuteRequestFailure() throws {
        let baseURL = try XCTUnwrap(URL(string: "https://domain.com"))
        let request = URLRequest(url: baseURL)
        let mockError = MockError()
        let task = NetworkTaskMock()
        networkTaskProvider.networkDataTaskHandler = { urlRequest, completion in
            XCTAssertEqual(urlRequest, request)
            completion(nil, nil, mockError)
            return task
        }
        
        service.execute(request: request, with: { data, response, error in
            XCTAssertNil(data)
            XCTAssertNil(response)
            XCTAssertEqual(error as? MockError, mockError)
        })
        
        XCTAssertEqual(task.resumeCallCount, 1)
        XCTAssertEqual(networkTaskProvider.networkDataTaskCallCount, 1)
        XCTAssertEqual(dispatchQueue.asyncCallCount, 1)
    }
    
    func testExecuteRequestWithResponse() throws {
        let baseURL = try XCTUnwrap(URL(string: "https://domain.com"))
        let request = URLRequest(url: baseURL)
        let networkData = Data()
        let networkResponse = HTTPURLResponse(url: baseURL,
                                              statusCode: 200,
                                              httpVersion: "HTTP/1.1",
                                              headerFields: nil)
        let task = NetworkTaskMock()
        networkTaskProvider.networkDataTaskHandler = { urlRequest, completion in
            XCTAssertEqual(urlRequest, request)
            completion(networkData, networkResponse, nil)
            return task
        }
        
        service.execute(request: request, with: { data, response, error in
            XCTAssertEqual(data, networkData)
            XCTAssertEqual(response, networkResponse)
            XCTAssertNil(error)
        })
        
        XCTAssertEqual(task.resumeCallCount, 1)
        XCTAssertEqual(networkTaskProvider.networkDataTaskCallCount, 1)
        XCTAssertEqual(dispatchQueue.asyncCallCount, 1)
    }
    
    func testExecuteHandlerSuccess() throws {
        let baseURL = try XCTUnwrap(URL(string: "https://domain.com"))
        let networkData = Data()
        let networkResponse = HTTPURLResponse(url: baseURL,
                                              statusCode: 200,
                                              httpVersion: "HTTP/1.1",
                                              headerFields: nil)
        let task = NetworkTaskMock()
        networkTaskProvider.networkDataTaskHandler = { _, completion in
            completion(networkData, networkResponse, nil)
            return task
        }
        
        var responseDeserializerCallCount = 0
        let handler: WebHandler<String> = .get(configuration: WebHandlerConfiguration(baseURL: baseURL),
                                               responseDeserializer: .init(deserialize: { statusCode, data in
            responseDeserializerCallCount += 1
            XCTAssertEqual(statusCode, networkResponse?.statusCode)
            XCTAssertEqual(data, networkData)
            return "String"
        }))
        
        var executeCallCount = 0
        service.execute(handler: handler, with: { result in
            executeCallCount += 1
            XCTAssertEqual(result.value, "String")
        })
        
        XCTAssertEqual(executeCallCount, 1)
        XCTAssertEqual(responseDeserializerCallCount, 1)
        XCTAssertEqual(task.resumeCallCount, 1)
        XCTAssertEqual(networkTaskProvider.networkDataTaskCallCount, 1)
        XCTAssertEqual(dispatchQueue.asyncCallCount, 1)
    }
    
    func testExecuteHandlerFailure() throws {
        let baseURL = try XCTUnwrap(URL(string: "https://domain.com"))
        let error = MockError()
        var responseDeserializerCallCount = 0
        let handler = WebHandler(configuration: WebHandlerConfiguration(baseURL: baseURL),
                                 httpMethod: .post,
                                 expectedStatusCode: 200,
                                 parameterSerializer: .init(contentType: .json,
                                                            serialize: { throw error }),
                                 responseDeserializer: .init(deserialize: { _, _ in
            responseDeserializerCallCount += 1
        }),
                                 errorDeserializer: nil)
        
        
        var executeCallCount = 0
        service.execute(handler: handler, with: { result in
            executeCallCount += 1
            XCTAssertEqual(result.error as? MockError, error)
        })
        
        XCTAssertEqual(executeCallCount, 1)
        XCTAssertEqual(responseDeserializerCallCount, 0)
        XCTAssertEqual(networkTaskProvider.networkDataTaskCallCount, 0)
        XCTAssertEqual(dispatchQueue.asyncCallCount, 1)
    }
}
