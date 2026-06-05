import XCTest
@testable import Soul

final class ReaderModeAITests: XCTestCase {
    
    func testSummarizeNoEndpointsOnline() {
        let ai = ReaderModeAI.shared
        
        let expectation = XCTestExpectation(description: "Wait for LLM error response")
        
        // Setup: Ensure all endpoints are marked offline for this test.
        for i in LLMConfigurator.shared.endpoints.indices {
            LLMConfigurator.shared.endpoints[i].isOnline = false
        }
        
        ai.summarize(html: "<p>Hello world</p>") { result in
            XCTAssertEqual(result, "No local LLM is currently running. Please start Ollama or LM Studio.")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
