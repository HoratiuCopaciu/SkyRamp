import XCTest
@testable import SkyRamp

final class SkyRampTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SkyRamp().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
