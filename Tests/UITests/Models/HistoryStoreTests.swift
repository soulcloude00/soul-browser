import XCTest
@testable import Soul

final class HistoryStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Ensure a clean slate for history tests
        HistoryStore.shared.clear()
    }
    
    override func tearDown() {
        // Clean up after tests
        HistoryStore.shared.clear()
        super.tearDown()
    }
    
    func testRecordingHistory() {
        let store = HistoryStore.shared
        let expectation = XCTestExpectation(description: "Wait for background DB insert")
        
        // Record a visit
        store.record(url: "https://apple.com", title: "Apple")
        
        // The record function uses async dispatch, so we need to wait briefly
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let suggestions = store.suggestions(for: "Apple")
            XCTAssertEqual(suggestions.count, 1)
            XCTAssertEqual(suggestions.first?.url, "https://apple.com")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testNonRecordableURLs() {
        let store = HistoryStore.shared
        let expectation = XCTestExpectation(description: "Wait for background DB insert")
        
        store.record(url: "about:blank", title: "Blank")
        store.record(url: "soul://settings", title: "Settings")
        store.record(url: "chrome://extensions", title: "Extensions")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // None of these should be recorded
            let blankSuggestions = store.suggestions(for: "Blank")
            let settingsSuggestions = store.suggestions(for: "Settings")
            
            XCTAssertTrue(blankSuggestions.isEmpty)
            XCTAssertTrue(settingsSuggestions.isEmpty)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testClearHistory() {
        let store = HistoryStore.shared
        let expectation = XCTestExpectation(description: "Wait for background DB insert")
        
        store.record(url: "https://github.com", title: "GitHub")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertFalse(store.suggestions(for: "GitHub").isEmpty)
            store.clear()
            XCTAssertTrue(store.suggestions(for: "GitHub").isEmpty)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
}
