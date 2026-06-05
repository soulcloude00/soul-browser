import SwiftUI

/// Color-space helpers so we can transcribe Soul's `globals.css` tokens
/// verbatim (many are authored in `oklch(...)`) and resolve them to sRGB with
/// full fidelity instead of eyeballing hex equivalents.
///
/// OKLCH is a perceptual color space that guarantees uniform lightness and chroma
/// scaling, preventing muddy transitions when interpolating colors in SwiftUI.
enum ColorMath {
    /// Convert `oklch(L C h)` (L in 0…1, C chroma, h in degrees) to sRGB
    /// components in 0…1. Mirrors the CSS Color 4 reference conversion:
    /// OKLCH → OKLab → linear-sRGB → gamma-encoded sRGB.
    ///
    /// - Parameters:
    ///   - L: Lightness value, ranging from 0.0 (black) to 1.0 (white).
    ///   - C: Chroma value, defining color intensity (typically 0.0 to 0.4).
    ///   - h: Hue angle in degrees (0.0 to 360.0).
    /// - Returns: A tuple representing gamma-encoded sRGB values in the 0...1 range.
    static func oklchToSRGB(L: Double, C: Double, h: Double) -> (r: Double, g: Double, b: Double) {
        let hr = h * .pi / 180.0
        let a = C * cos(hr)
        let bb = C * sin(hr)

        // OKLab -> LMS (nonlinear)
        let l_ = L + 0.3963377774 * a + 0.2158037573 * bb
        let m_ = L - 0.1055613458 * a - 0.0638541728 * bb
        let s_ = L - 0.0894841775 * a - 1.2914855480 * bb

        let l = l_ * l_ * l_
        let m = m_ * m_ * m_
        let s = s_ * s_ * s_

        // LMS -> linear sRGB conversion matrix
        let rLin = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
        let gLin = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
        let bLin = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s

        return (gammaEncode(rLin), gammaEncode(gLin), gammaEncode(bLin))
    }

    /// Converts a linear-sRGB component to gamma-encoded sRGB, clamped to the display range.
    ///
    /// - Parameter c: The linear color channel value.
    /// - Returns: The gamma-encoded channel value (0...1).
    private static func gammaEncode(_ c: Double) -> Double {
        let clamped = min(max(c, 0.0), 1.0)
        if clamped <= 0.0031308 {
            return 12.92 * clamped
        }
        return 1.055 * pow(clamped, 1.0 / 2.4) - 0.055
    }
}

/// A flexible theme color representation authored either as a Hex string or an OKLCH tuple,
/// supporting an optional alpha channel. Matches exactly the design token syntax used across `globals.css`.
struct TokenColor {
    /// Red channel (0...1)
    let r: Double
    /// Green channel (0...1)
    let g: Double
    /// Blue channel (0...1)
    let b: Double
    /// Alpha/Opacity channel (0...1)
    let a: Double

    /// Initializes a `TokenColor` using raw sRGB values.
    init(r: Double, g: Double, b: Double, a: Double = 1) {
        self.r = r; self.g = g; self.b = b; self.a = a
    }

    /// Initializes a `TokenColor` from a standard hex string representation.
    ///
    /// Supports the following formats:
    /// - `#rgb`
    /// - `#rrggbb`
    /// - `#rrggbbaa`
    ///
    /// - Parameters:
    ///   - hex: The hex string (e.g., "#FF0000").
    ///   - alpha: An optional alpha override, defaulting to 1.0.
    init(hex: String, alpha: Double = 1) {
        var s = hex.trimmingCharacters(in: .whitespaces)
        if s.hasPrefix("#") { s.removeFirst() }
        
        // Expand shorthand hex notation
        if s.count == 3 {
            s = s.map { "\($0)\($0)" }.joined()
        }
        
        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)
        
        let hasAlpha = s.count == 8
        if hasAlpha {
            r = Double((value >> 24) & 0xFF) / 255
            g = Double((value >> 16) & 0xFF) / 255
            b = Double((value >> 8) & 0xFF) / 255
            a = Double(value & 0xFF) / 255
        } else {
            r = Double((value >> 16) & 0xFF) / 255
            g = Double((value >> 8) & 0xFF) / 255
            b = Double(value & 0xFF) / 255
            a = alpha
        }
    }

    /// Initializes a `TokenColor` directly from OKLCH color space values.
    ///
    /// - Parameters:
    ///   - L: Lightness (0...1).
    ///   - C: Chroma magnitude.
    ///   - h: Hue angle (degrees).
    ///   - alpha: Opacity level.
    init(L: Double, C: Double, h: Double, alpha: Double = 1) {
        let rgb = ColorMath.oklchToSRGB(L: L, C: C, h: h)
        r = rgb.r; g = rgb.g; b = rgb.b; a = alpha
    }

    /// Generates a native SwiftUI `Color` struct instance from this token.
    var color: Color {
        Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    /// Generates a native AppKit `NSColor` instance from this token.
    var nsColor: NSColor {
        NSColor(srgbRed: r, green: g, blue: b, alpha: a)
    }

    /// Creates a copy of this `TokenColor` with an overridden opacity value.
    ///
    /// - Parameter value: The new alpha value (0...1).
    /// - Returns: A mutated `TokenColor` instance.
    func opacity(_ value: Double) -> TokenColor {
        TokenColor(r: r, g: g, b: b, a: value)
    }
}

extension TokenColor {
    /// Factory convenience method for hex instantiation.
    static func hex(_ h: String, _ alpha: Double = 1) -> TokenColor { TokenColor(hex: h, alpha: alpha) }
    
    /// Factory convenience method for OKLCH instantiation.
    static func oklch(_ L: Double, _ C: Double, _ h: Double, _ alpha: Double = 1) -> TokenColor {
        TokenColor(L: L, C: C, h: h, alpha: alpha)
    }
}
