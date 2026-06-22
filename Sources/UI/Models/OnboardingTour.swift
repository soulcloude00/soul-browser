import SwiftUI

/// Interactive Tutorial / Onboarding Tour
final class OnboardingTour: ObservableObject {
    static let shared = OnboardingTour()

    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "soul.completedOnboarding") }
    }
    @Published var currentStep = 0

    enum Step: Int, CaseIterable {
        case welcome = 0
        case services
        case searchEngine
        case dataImport
        case defaultBrowser
        case finish
    }

    private init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "soul.completedOnboarding")
    }

    func nextStep() {
        if currentStep < Step.allCases.count - 1 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                currentStep += 1
            }
        } else {
            complete()
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                currentStep -= 1
            }
        }
    }

    func complete() {
        withAnimation {
            hasCompletedOnboarding = true
            currentStep = 0
        }
    }

    func reset() {
        hasCompletedOnboarding = false
        currentStep = 0
    }
}
