import SwiftUI

struct OnboardingView: View {
    @ObservedObject var tour: OnboardingTour
    @Environment(\.palette) private var p
    @State private var hoveringSkip = false
    @State private var hoveringPrimary = false

    private var step: OnboardingStep {
        tour.steps[min(tour.currentStep, tour.steps.count - 1)]
    }

    private var progress: CGFloat {
        guard tour.steps.count > 1 else { return 1 }
        return CGFloat(tour.currentStep + 1) / CGFloat(tour.steps.count)
    }

    private var isLastStep: Bool {
        tour.currentStep >= tour.steps.count - 1
    }

    var body: some View {
        ZStack {
            VisualEffectBackground(material: .hudWindow)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    p.primary.color.opacity(0.18),
                    p.background.color.opacity(0.68),
                    p.accent.color.opacity(0.14)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 26) {
                header
                card
                footer
            }
            .padding(32)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.985)))
    }

    private var header: some View {
        HStack {
            HStack(spacing: 10) {
                Icon(name: "soul", size: 22, weight: .regular)
                    .foregroundStyle(p.primary.color)
                Text("Soul")
                    .font(Typography.ui(18, weight: .semibold))
                    .foregroundStyle(p.foreground.color)
            }

            Spacer()

            Button {
                withAnimation(Motion.reveal) { tour.complete() }
            } label: {
                Text("Skip")
                    .font(Typography.ui(Typography.base, weight: .medium))
                    .foregroundStyle(p.mutedForeground.color)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
                            .fill(hoveringSkip ? p.foreground.color.opacity(0.06) : .clear)
                    )
            }
            .buttonStyle(.plain)
            .onHover { hoveringSkip = $0 }
            .animation(Motion.state, value: hoveringSkip)
        }
        .frame(maxWidth: 860)
    }

    private var card: some View {
        HStack(spacing: 0) {
            visualPanel
                .frame(width: 330)

            Hairline(vertical: true)
                .opacity(0.6)

            VStack(alignment: .leading, spacing: 22) {
                progressBar

                VStack(alignment: .leading, spacing: 12) {
                    Text(step.title)
                        .font(Typography.ui(34, weight: .semibold))
                        .foregroundStyle(p.foreground.color)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(step.description)
                        .font(Typography.ui(15, weight: .regular))
                        .foregroundStyle(p.mutedForeground.color)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .id(step.id)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                featureGrid

                Spacer(minLength: 0)

                HStack(spacing: 10) {
                    stepDots
                    Spacer()
                    primaryButton
                }
            }
            .padding(30)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .frame(width: 860, height: 430)
        .background(
            RoundedRectangle(cornerRadius: Radius.popover + 8, style: .continuous)
                .fill(p.popover.color.opacity(0.96))
                .shadow(color: .black.opacity(0.28), radius: 34, y: 18)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.popover + 8, style: .continuous)
                .strokeBorder(p.border.color.opacity(0.58), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.popover + 8, style: .continuous))
    }

    private var visualPanel: some View {
        ZStack {
            LinearGradient(
                colors: [p.primary.color.opacity(0.18), p.card.color.opacity(0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(p.primary.color.opacity(0.12))
                        .frame(width: 136, height: 136)
                    Circle()
                        .strokeBorder(p.primary.color.opacity(0.22), lineWidth: 1)
                        .frame(width: 136, height: 136)
                    Icon(name: step.icon, size: 54, weight: .light)
                        .foregroundStyle(p.primary.color)
                }
                .id("icon-\(step.id)")
                .transition(.scale(scale: 0.82).combined(with: .opacity))

                VStack(spacing: 8) {
                    Text("LOCAL-FIRST")
                        .font(Typography.ui(Typography.small, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(p.mutedForeground.color)
                    Text("AI browsing without giving up control")
                        .font(Typography.ui(14, weight: .medium))
                        .foregroundStyle(p.foreground.color)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .frame(maxWidth: 220)
                }
            }
            .padding(24)
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(p.foreground.color.opacity(0.09))
                Capsule()
                    .fill(p.primary.color)
                    .frame(width: geo.size.width * progress)
            }
        }
        .frame(height: 4)
        .animation(Motion.snappy, value: tour.currentStep)
    }

    private var featureGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            OnboardingFeature(icon: "brain", title: "Codex assistant", text: "Summaries, actions, and page-aware help.")
            OnboardingFeature(icon: "shield.checkerboard", title: "Privacy tools", text: "Tracker blocking and fingerprint protection.")
            OnboardingFeature(icon: "sidebar.right", title: "Spatial tabs", text: "A calm sidebar for focused browsing.")
            OnboardingFeature(icon: "command", title: "Fast control", text: "Use ⌘K, ⌘L, and shortcuts everywhere.")
        }
    }

    private var stepDots: some View {
        HStack(spacing: 7) {
            ForEach(tour.steps.indices, id: \.self) { index in
                Capsule()
                    .fill(index == tour.currentStep ? p.primary.color : p.foreground.color.opacity(0.16))
                    .frame(width: index == tour.currentStep ? 20 : 7, height: 7)
            }
        }
        .animation(Motion.snappy, value: tour.currentStep)
    }

    private var primaryButton: some View {
        Button {
            withAnimation(Motion.reveal) { tour.nextStep() }
        } label: {
            HStack(spacing: 8) {
                Text(isLastStep ? "Start browsing" : "Continue")
                    .font(Typography.ui(Typography.base, weight: .semibold))
                Icon(name: isLastStep ? "arrow.right.circle" : "arrow.right", size: 14, weight: .semibold)
            }
            .foregroundStyle(p.primaryForeground.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
                    .fill(p.primary.color.opacity(hoveringPrimary ? 0.92 : 1))
            )
        }
        .buttonStyle(.plain)
        .onHover { hoveringPrimary = $0 }
        .animation(Motion.state, value: hoveringPrimary)
    }

    private var footer: some View {
        Text("You can replay this anytime from the app menu.")
            .font(Typography.ui(Typography.small, weight: .medium))
            .foregroundStyle(p.mutedForeground.color)
    }
}

private struct OnboardingFeature: View {
    let icon: String
    let title: String
    let text: String
    @Environment(\.palette) private var p

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Icon(name: icon, size: 16, weight: .medium)
                .foregroundStyle(p.primary.color)
                .frame(width: 24, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(p.primary.color.opacity(0.10))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(Typography.ui(13, weight: .semibold))
                    .foregroundStyle(p.foreground.color)
                Text(text)
                    .font(Typography.ui(12, weight: .regular))
                    .foregroundStyle(p.mutedForeground.color)
                    .lineLimit(2)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .fill(p.card.color.opacity(0.62))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                .strokeBorder(p.border.color.opacity(0.42), lineWidth: 1)
        )
    }
}
