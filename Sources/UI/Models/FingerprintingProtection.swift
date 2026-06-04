import Foundation

/// Fingerprinting Protection (Roadmap Item 62)
/// Intercepts and spoofs common browser telemetry targets (Canvas API,
/// WebGL signatures, navigator strings, screen parameters) to prevent
/// advertising networks from building a unique profile.
final class FingerprintingProtection {
    static let shared = FingerprintingProtection()

    private init() {}

    func injectProtectionScript() -> String {
        """
        (function() {
            if (window.__soulFingerprintProtection) return;
            window.__soulFingerprintProtection = true;

            // Canvas noise
            const origGetImageData = CanvasRenderingContext2D.prototype.getImageData;
            CanvasRenderingContext2D.prototype.getImageData = function(x, y, w, h) {
                const img = origGetImageData.call(this, x, y, w, h);
                for (let i = 0; i < img.data.length; i += 4) {
                    img.data[i] = (img.data[i] + (Math.random() > 0.5 ? 1 : -1)) & 0xFF;
                }
                return img;
            };

            // WebGL vendor/renderer spoof
            const getParam = WebGLRenderingContext.prototype.getParameter;
            WebGLRenderingContext.prototype.getParameter = function(p) {
                if (p === 0x1F00) return 'Apple Inc.'; // UNMASKED_VENDOR_WEBGL
                if (p === 0x1F01) return 'Apple GPU'; // UNMASKED_RENDERER_WEBGL
                return getParam.call(this, p);
            };

            // Navigator plugin reduction
            Object.defineProperty(navigator, 'plugins', {
                get: function() { return { length: 0 }; }
            });

            // Screen size rounding
            Object.defineProperty(screen, 'width', { get: () => Math.round(screen.width / 10) * 10 });
            Object.defineProperty(screen, 'height', { get: () => Math.round(screen.height / 10) * 10 });
        })();
        """
    }
}
