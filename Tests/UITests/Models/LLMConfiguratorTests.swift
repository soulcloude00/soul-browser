import XCTest
@testable import Soul

final class LLMConfiguratorTests: XCTestCase {
    
    func testEndpointInitialization() {
        let configurator = LLMConfigurator.shared
        
        XCTAssertEqual(configurator.endpoints.count, 2)
        XCTAssertEqual(configurator.endpoints[0].type, .ollama)
        XCTAssertEqual(configurator.endpoints[1].type, .lmStudio)
        
        XCTAssertEqual(configurator.endpoints[0].port, 11434)
        XCTAssertEqual(configurator.endpoints[1].port, 1234)
    }
    
    func testAddCustomEndpoint() {
        let configurator = LLMConfigurator.shared
        let initialCount = configurator.endpoints.count
        
        configurator.addCustomEndpoint(name: "My API", url: "http://localhost:8080", port: 8080)
        
        XCTAssertEqual(configurator.endpoints.count, initialCount + 1)
        
        let last = configurator.endpoints.last!
        XCTAssertEqual(last.name, "My API")
        XCTAssertEqual(last.url, "http://localhost:8080")
        XCTAssertEqual(last.port, 8080)
        XCTAssertEqual(last.type, .custom)
    }
}
