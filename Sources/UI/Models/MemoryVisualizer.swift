import Foundation

/// Custom Memory Footprint Visualizer (Roadmap Item 26)
/// Queries process memory statistics for CEF renderer and GPU helpers and
/// renders them in a visual panel.
final class MemoryVisualizer: ObservableObject {
    static let shared = MemoryVisualizer()

    @Published var rendererMB: Double = 0
    @Published var gpuMB: Double = 0
    @Published var browserMB: Double = 0
    @Published var totalMB: Double = 0

    private var timer: Timer?

    private init() {
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    func refresh() {
        var info = task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<task_basic_info>.size) / 4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_BASIC_INFO), $0, &count)
            }
        }
        if kerr == KERN_SUCCESS {
            let usedMB = Double(info.resident_size) / 1024 / 1024
            browserMB = usedMB
            totalMB = usedMB + rendererMB + gpuMB
        }
    }

    func updateRendererMemory(_ mb: Double) { rendererMB = mb }
    func updateGPUMemory(_ mb: Double) { gpuMB = mb }
}
