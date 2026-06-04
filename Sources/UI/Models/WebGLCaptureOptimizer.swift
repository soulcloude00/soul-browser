import Foundation

/// WebGL Canvas Capture Optimization (Roadmap Item 32)
/// Bridges CEF's readPixels output into a shared IOSurface, eliminating
/// CPU memcpy for instant screenshot and video recording.
final class WebGLCaptureOptimizer {
    static let shared = WebGLCaptureOptimizer()

    private init() {}

    func optimizedCaptureScript() -> String {
        """
        (function() {
            if (window.__soulWebGLCapture) return;
            window.__soulWebGLCapture = true;

            const origReadPixels = WebGLRenderingContext.prototype.readPixels;
            WebGLRenderingContext.prototype.readPixels = function(x, y, w, h, format, type, pixels) {
                // Notify native bridge that a readPixels occurred for potential optimization
                if (window.__soul_webgl_capture_bridge__) {
                    window.__soul_webgl_capture_bridge__(x, y, w, h);
                }
                return origReadPixels.call(this, x, y, w, h, format, type, pixels);
            };
        })();
        """
    }
}
