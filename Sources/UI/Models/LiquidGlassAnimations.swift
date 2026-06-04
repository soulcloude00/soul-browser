import SwiftUI

/// Liquid Glass Fluid Animations (Roadmap Item 81)
/// Applies physical spring animations to all UI adjustments.
enum LiquidGlassAnimations {
    static var spring: Animation {
        .spring(response: 0.35, dampingFraction: 0.7)
    }

    static var snappy: Animation {
        .spring(response: 0.25, dampingFraction: 0.8)
    }

    static var reveal: Animation {
        .spring(response: 0.45, dampingFraction: 0.6)
    }
}

extension View {
    func liquidGlassSpring() -> some View {
        animation(LiquidGlassAnimations.spring, value: true)
    }
}
