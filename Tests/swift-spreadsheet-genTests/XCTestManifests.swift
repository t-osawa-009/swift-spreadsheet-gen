import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(swift_spreadsheet_genTests.allTests),
    ]
}
#endif
