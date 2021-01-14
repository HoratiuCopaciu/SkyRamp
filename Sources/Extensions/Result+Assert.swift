//
//  Result+Assert.swift
//
//  Created by Horatiu Copaciu on 07/05/2020.
//  Copyright © 2020 Horatiu Copaciu. All rights reserved.
//

import XCTest

public extension Result where Success == Void {
    func assertSuccess() {
        switch self {
        case .success:
            break
        case let .failure(error):
            XCTFail("Unexpected failure: \(error)")
        }
    }
}

public extension Result where Success: Equatable {
    func assertSuccess(value: Success) {
        switch self {
        case .success(let resultValue):
            XCTAssertEqual(resultValue, value)
        case .failure(let error):
            XCTFail("Unexpected failure: \(error)")
        }
    }
}

public extension Result {
    func assertFailure(_ message: String) {
        switch self {
        case let .success(value):
            XCTFail("Unexpected success: \(value)")
        case let .failure(error):
            XCTAssertEqual(error.localizedDescription, message)
        }
    }
}
