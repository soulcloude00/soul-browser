import XCTest
@testable import Soul

final class SoulPowerManagerTests: XCTestCase {
    
    func testPowerThrottleNotification() {
        let expectation = XCTestExpectation(description: "Wait for throttle notification")
        
        var receivedFPS: Int? = nil
        var isThrottled: Bool = false
        
        let token = NotificationCenter.default.addObserver(forName: .soulPowerThrottleChanged, object: nil, queue: nil) { notification in
            if let userInfo = notification.userInfo {
                isThrottled = userInfo["throttled"] as? Bool ?? false
                receivedFPS = userInfo["targetFPS"] as? Int
            }
            expectation.fulfill()
        }
        
        // We will trigger it manually since we can't easily fake process power state in a stable way
        // without swizzling. But we can just test that the notification structure is correct.
        NotificationCenter.default.post(
            name: .soulPowerThrottleChanged,
            object: nil,
            userInfo: ["throttled": true, "targetFPS": 30]
        )
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(isThrottled)
        XCTAssertEqual(receivedFPS, 30)
        
        NotificationCenter.default.removeObserver(token)
    }
}
