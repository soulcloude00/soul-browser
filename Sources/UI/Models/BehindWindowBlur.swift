import SwiftUI
import AppKit

/// Behind-Window Backdrop Blur Overlay (Roadmap Item 86)
/// Binds NSVisualEffectView behaviors dynamically to window focus changes so
/// the sidebar and panels dim elegantly when Soul goes into the background.
struct BehindWindowBlur: NSViewRepresentable {
    @Binding var isActive: Bool

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .contentBackground
        updateNSView(view, context: context)
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = isActive ? .contentBackground : .underWindowBackground
        nsView.alphaValue = isActive ? 1.0 : 0.7
    }
}
