import SwiftUI

/// Interactive Tutorial / Onboarding Tour (Roadmap Item 92)
/// Build an elegant SwiftUI onboarding experience that showcases the AI Panel,
/// sidebar, and theme customizer.
final class OnboardingTour: ObservableObject {
    static let shared = OnboardingTour()

    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "soul.completedOnboarding") }
    }
    @Published var currentStep = 0

    let steps: [OnboardingStep] = [
        OnboardingStep(title: "Welcome to Soul", description: "The local-first AI browser for macOS.", icon: "sparkles"),
        OnboardingStep(title: "AI Panel", description: "Press ⌘J to open the AI assistant. It runs entirely on your device.", icon: "brain"),
        OnboardingStep(title: "Sidebar", description: "Organize tabs into workspaces, folders, and pinned grids.", icon: "sidebar.left"),
        OnboardingStep(title: "Theme Customizer", description: "Choose from gradient presets or craft your own with OKLCH.", icon: "paintbrush"),
        OnboardingStep(title: "Privacy First", description: "Built-in tracker blocking, fingerprint protection, and private sessions.", icon: "shield.checkerboard"),
        OnboardingStep(title: "You're Ready", description: "Start browsing with Soul.", icon: "arrow.right.circle")
    ]

    private init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "soul.completedOnboarding")
    }

    func nextStep() {
        if currentStep < steps.count - 1 {
            currentStep += 1
        } else {
            complete()
        }
    }

    func complete() {
        hasCompletedOnboarding = true
        currentStep = 0
    }

    func reset() {
        hasCompletedOnboarding = false
        currentStep = 0
    }
}

struct OnboardingStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}
