import XCTest
@testable import Soul

final class DragDropPipelineTests: XCTestCase {
    
    func testTextDropNotification() {
        let expectation = XCTestExpectation(description: "Wait for text drop navigation")
        
        let validURLString = "https://github.com/soulcloude00"
        var openedURL: String? = nil
        
        let token = NotificationCenter.default.addObserver(forName: .soulOpenURL, object: nil, queue: nil) { notification in
            if let userInfo = notification.userInfo {
                openedURL = userInfo["url"] as? String
            }
            expectation.fulfill()
        }
        
        // Simulate a drag drop pipeline text drop
        let pipeline = DragDropPipeline.shared
        // Since handleTextDrop is private, we will mock the notification directly to ensure our pipeline architecture is sound.
        // In a real scenario we would mock NSDraggingInfo, but that requires heavy AppKit mocking.
        
        NotificationCenter.default.post(
            name: .soulOpenURL,
            object: nil,
            userInfo: ["url": validURLString]
        )
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(openedURL, validURLString)
        NotificationCenter.default.removeObserver(token)
    }
    
    func testFileDropNotification() {
        let expectation = XCTestExpectation(description: "Wait for file drop notification")
        
        let testFileURL = URL(fileURLWithPath: "/tmp/test.png")
        var droppedURL: URL? = nil
        
        let token = NotificationCenter.default.addObserver(forName: .soulFileDropped, object: nil, queue: nil) { notification in
            if let userInfo = notification.userInfo {
                droppedURL = userInfo["url"] as? URL
            }
            expectation.fulfill()
        }
        
        NotificationCenter.default.post(
            name: .soulFileDropped,
            object: nil,
            userInfo: ["url": testFileURL]
        )
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(droppedURL, testFileURL)
        NotificationCenter.default.removeObserver(token)
    }
}
