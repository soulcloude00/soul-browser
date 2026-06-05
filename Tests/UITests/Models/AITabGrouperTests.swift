import XCTest
@testable import Soul

final class AITabGrouperTests: XCTestCase {
    
    func testSuggestGroupsEmpty() {
        let grouper = AITabGrouper.shared
        
        let expectation = XCTestExpectation(description: "Wait for AI tab grouping")
        
        grouper.suggestGroupsWithAI(for: []) { groups in
            XCTAssertTrue(groups.isEmpty)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
