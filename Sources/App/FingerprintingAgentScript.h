// JavaScript agent injected at the start of every frame to reduce
// browser fingerprinting entropy (Canvas noise, WebGL spoof, plugin
// reduction, screen rounding).
#pragma once

static const char kSoulFingerprintingAgent[] = R"JS(
(function() {
    if (window.__soulFingerprintProtection) return;
    window.__soulFingerprintProtection = true;

    // Canvas noise: perturb 1 random channel per 4-byte pixel block
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
        if (p === 0x1F01) return 'Apple GPU';  // UNMASKED_RENDERER_WEBGL
        return getParam.call(this, p);
    };

    // Navigator plugin reduction
    Object.defineProperty(navigator, 'plugins', {
        get: function() { return { length: 0 }; }
    });

    // Screen size rounding (to nearest 10px)
    Object.defineProperty(screen, 'width',  { get: () => Math.round(screen.width  / 10) * 10 });
    Object.defineProperty(screen, 'height', { get: () => Math.round(screen.height / 10) * 10 });
})();
)JS";
