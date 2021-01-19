//
//  NetworkResponseTests.swift
//  
//
//  Created by Horatiu Copaciu on 19/01/2021.
//

import XCTest
import SkyRamp

class NetworkResponseTests<Value>: XCTestCase {
    
    var sut: NetworkResponse<Value>!
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
}
