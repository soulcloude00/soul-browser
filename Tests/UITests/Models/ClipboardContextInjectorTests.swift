import XCTest
@testable import Soul

final class ClipboardContextInjectorTests: XCTestCase {
    
    func testAcknowledgeClearsHasNewContent() {
        let injector = ClipboardContextInjector.shared
        injector.hasNewContent = true
        injector.acknowledge()
        XCTAssertFalse(injector.hasNewContent)
    }
    
    func testAnalyzeEmptyContent() {
        let injector = ClipboardContextInjector.shared
        injector.currentContent = ""
        
        let expectation = XCTestExpectation(description: "Wait for LLM empty response")
        injector.analyzeContent(action: .explain) { result in
            XCTAssertEqual(result, "Clipboard is empty.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
