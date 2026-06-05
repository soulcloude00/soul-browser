import XCTest
@testable import Soul

final class MemoryVisualizerTests: XCTestCase {
    
    func testMemoryVisualizerInitialization() {
        let visualizer = MemoryVisualizer.shared
        XCTAssertNotNil(visualizer)
        XCTAssertEqual(visualizer.rendererMB, 0)
        XCTAssertEqual(visualizer.gpuMB, 0)
    }
    
    func testUpdateMemory() {
        let visualizer = MemoryVisualizer.shared
        
        visualizer.updateRendererMemory(150.5)
        XCTAssertEqual(visualizer.rendererMB, 150.5)
        
        visualizer.updateGPUMemory(85.2)
        XCTAssertEqual(visualizer.gpuMB, 85.2)
    }
}
