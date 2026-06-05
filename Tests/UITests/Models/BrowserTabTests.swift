import XCTest
@testable import Soul

final class BrowserTabTests: XCTestCase {
    func testInitialization() {
        let tab = BrowserTab(url: "https://apple.com", title: "Apple")
        XCTAssertEqual(tab.urlString, "https://apple.com")
        XCTAssertEqual(tab.title, "Apple")
        XCTAssertFalse(tab.isLoading)
        XCTAssertFalse(tab.hasRealized, "Browser view should not be realized until necessary")
        XCTAssertEqual(tab.zoomPercent, 100)
    }
    
    func testZoomLogic() {
        let tab = BrowserTab(url: "https://apple.com")
        XCTAssertEqual(tab.zoomPercent, 100)
        
        // Simulating the native zoom logic without realizing the view
        tab.setZoomFactor(1.2)
        XCTAssertEqual(tab.zoomPercent, 120)
        
        tab.setZoomFactor(1.44)
        XCTAssertEqual(tab.zoomPercent, 144)
        
        tab.resetZoom()
        XCTAssertEqual(tab.zoomPercent, 100)
    }
    
    func testDisplayURL() {
        let emptyTab = BrowserTab(url: "about:blank")
        XCTAssertEqual(emptyTab.displayURL, "")
        
        let internalTab = BrowserTab(url: "soul://settings")
        XCTAssertEqual(internalTab.displayURL, "")
        
        let webTab = BrowserTab(url: "https://github.com")
        XCTAssertEqual(webTab.displayURL, "https://github.com")
    }
    
    func testURLSchemeParsing() {
        let tab = BrowserTab(url: "HTTPS://google.com")
        XCTAssertEqual(tab.urlScheme, "https")
    }
}
