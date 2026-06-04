import SwiftUI

/// Adaptive Favicon Coloring (Roadmap Item 87)
/// Extracts the dominant color of a favicon and uses it to tint the tab's
/// highlight ring and text for faster visual scanning.
final class AdaptiveFaviconColor {
    static let shared = AdaptiveFaviconColor()

    private init() {}

    func extractDominantColor(from image: NSImage?) -> Color {
        guard let image = image,
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
        else { return .gray }

        let width = cgImage.width
        let height = cgImage.height
        guard width > 0 && height > 0 else { return .gray }

        let bitmapData = UnsafeMutablePointer<UInt32>.allocate(capacity: width * height)
        defer { bitmapData.deallocate() }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: bitmapData,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: width * 4,
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var r: UInt64 = 0, g: UInt64 = 0, b: UInt64 = 0
        let count = width * height
        for i in 0..<count {
            let pixel = bitmapData[i]
            r += UInt64((pixel >> 16) & 0xFF)
            g += UInt64((pixel >> 8) & 0xFF)
            b += UInt64(pixel & 0xFF)
        }

        return Color(
            red: Double(r) / Double(count) / 255.0,
            green: Double(g) / Double(count) / 255.0,
            blue: Double(b) / Double(count) / 255.0
        )
    }
}
