import XCTest
@testable import App

class FooTests: XCTestCase {
    
    static let allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testExample", testExample),
    ]
    
    func testExample() {
        XCTAssertTrue(true)
    }
    
    // MARK: Linux Helper

    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let thisClass = type(of: self)
            let linuxCount = thisClass.allTests.count
            let darwinCount = Int(thisClass
                .defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount,
                "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }
    
}
