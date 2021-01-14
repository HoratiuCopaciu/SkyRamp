//
//  XCTestCase+Async.swift
//
//  Created by Horatiu Copaciu on 07/05/2020.
//  Copyright © 2020 Horatiu Copaciu. All rights reserved.
//

import XCTest

public extension XCTestCase {
    
    func expectation(description: String, _ block: (XCTestExpectation) -> Void, timeout: TimeInterval = 1) {
        let expectation = XCTestExpectation(description: description)
        block(expectation)
        wait(for: [expectation], timeout: timeout)
    }
}
