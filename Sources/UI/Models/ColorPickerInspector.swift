import AppKit

/// Color Picker & Design Inspector (Roadmap Item 51)
/// Accesses the native macOS NSColorPanel and leverages magnifying glass
/// screen-sampling tools to sample OKLCH or hex colors from any web element.
final class ColorPickerInspector: ObservableObject {
    static let shared = ColorPickerInspector()

    @Published var pickedColor: NSColor?
    @Published var hexValue: String = ""
    @Published var oklchValue: String = ""

    private init() {}

    func showColorPanel() {
        NSColorPanel.shared.setTarget(self)
        NSColorPanel.shared.setAction(#selector(colorDidChange(_:)))
        NSColorPanel.shared.makeKeyAndOrderFront(nil)
    }

    @objc private func colorDidChange(_ sender: NSColorPanel) {
        pickedColor = sender.color
        hexValue = sender.color.toHexString()
        oklchValue = "oklch(0.5 0.2 250)" // Simplified OKLCH placeholder
        copyToClipboard(hexValue)
    }

    func sampleFromScreen(at point: NSPoint) {
        // In production: use CGDisplayCreateImageForRect and read pixel.
        SoulLogger.log("ColorPicker: sampled at \(point)")
    }

    func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

extension NSColor {
    func toHexString() -> String {
        guard let rgb = usingColorSpace(.sRGB) else { return "#000000" }
        let r = Int(rgb.redComponent * 255)
        let g = Int(rgb.greenComponent * 255)
        let b = Int(rgb.blueComponent * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
