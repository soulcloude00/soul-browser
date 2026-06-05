import SwiftUI

// MARK: - Onboarding

struct OnboardingView: View {
    @ObservedObject var tour: OnboardingTour
    @Environment(\.palette) private var p

    @State private var hoveringSkip = false
    @State private var hoveringBack = false
    @State private var hoveringNext = false

    private var stages: [OnboardingStage] { OnboardingStage.all }
    private var stepCount: Int { stages.count }
    private var index: Int { min(max(tour.currentStep, 0), stepCount - 1) }
    private var stage: OnboardingStage { stages[index] }
    private var isFirst: Bool { index == 0 }
    private var isLast: Bool { index == stepCount - 1 }
    private var progress: CGFloat { CGFloat(index + 1) / CGFloat(stepCount) }

    var body: some View {
        ZStack {
            Backdrop(tint: stage.tint)

            card
                .frame(width: 940, height: 600)
                .background(cardSurface)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(p.border.color.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 48, y: 26)
        }
        .onExitCommand { complete() }
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }

    private var cardSurface: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(p.popover.color.opacity(0.98))
    }

    // MARK: Card

    private var card: some View {
        HStack(spacing: 0) {
            showcase
                .frame(width: 408)

            Rectangle()
                .fill(p.border.color.opacity(0.55))
                .frame(width: 1)

            content
        }
    }

    // MARK: Showcase (left)

    private var showcase: some View {
        ZStack {
            LinearGradient(
                colors: [
                    stage.tint.opacity(0.28),
                    p.card.color.opacity(0.6),
                    p.background.color.opacity(0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    brand
                    Spacer()
                    StepCounter(current: index + 1, total: stepCount)
                }

                Spacer(minLength: 0)

                StagePreview(stage: stage)
                    .frame(height: 280)
                    .id(stage.id)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.97)),
                        removal: .opacity
                    ))

                Spacer(minLength: 0)

                HStack(spacing: 8) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(stage.tint)
                    Text("Runs locally. Private by default.")
                        .font(Typography.ui(12, weight: .medium))
                        .foregroundStyle(p.mutedForeground.color)
                }
            }
            .padding(28)
        }
        .animation(Motion.reveal, value: index)
    }

    private var brand: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(stage.tint.opacity(0.16))
                Icon(name: "soul", size: 18, weight: .regular)
                    .foregroundStyle(stage.tint)
            }
            .frame(width: 32, height: 32)

            Text("Soul")
                .font(Typography.ui(16, weight: .semibold))
                .foregroundStyle(p.foreground.color)
        }
    }

    // MARK: Content (right)

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            HStack {
                Text(stage.eyebrow.uppercased())
                    .font(Typography.ui(11, weight: .bold))
                    .tracking(1.6)
                    .foregroundStyle(stage.tint)
                Spacer()
                skipButton
            }
            .padding(.bottom, 22)

            // Title + body
            VStack(alignment: .leading, spacing: 14) {
                Text(stage.title)
                    .font(Typography.ui(30, weight: .semibold))
                    .foregroundStyle(p.foreground.color)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(stage.body)
                    .font(Typography.ui(15, weight: .regular))
                    .foregroundStyle(p.mutedForeground.color)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 420, alignment: .leading)
            .id("copy-\(stage.id)")
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))

            Spacer(minLength: 28)

            // Feature list
            VStack(spacing: 12) {
                ForEach(stage.points) { point in
                    FeatureRow(point: point, tint: stage.tint)
                }
            }
            .id("points-\(stage.id)")
            .transition(.opacity)

            Spacer(minLength: 28)

            // Progress + controls
            VStack(spacing: 18) {
                ProgressTrack(progress: progress, tint: stage.tint)
                controls
            }
        }
        .padding(36)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .animation(Motion.reveal, value: index)
    }

    private var skipButton: some View {
        Button(action: complete) {
            Text("Skip")
                .font(Typography.ui(13, weight: .medium))
                .foregroundStyle(hoveringSkip ? p.foreground.color : p.mutedForeground.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(hoveringSkip ? p.foreground.color.opacity(0.08) : .clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { hoveringSkip = $0 }
        .animation(Motion.state, value: hoveringSkip)
    }

    private var controls: some View {
        HStack(spacing: 12) {
            StepDots(count: stepCount, index: index, tint: stage.tint) { goto($0) }

            Spacer()

            if !isFirst {
                Button(action: back) {
                    Text("Back")
                        .font(Typography.ui(14, weight: .semibold))
                        .foregroundStyle(p.foreground.color)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 11)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
                                .fill(hoveringBack ? p.foreground.color.opacity(0.08) : p.card.color.opacity(0.55))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
                                .strokeBorder(p.border.color.opacity(0.5), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .onHover { hoveringBack = $0 }
                .animation(Motion.state, value: hoveringBack)
                .transition(.opacity)
            }

            Button(action: next) {
                HStack(spacing: 8) {
                    Text(isLast ? "Start browsing" : "Continue")
                        .font(Typography.ui(14, weight: .semibold))
                    Image(systemName: isLast ? "checkmark" : "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(p.primaryForeground.color)
                .padding(.horizontal, 20)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
                        .fill(stage.tint.opacity(hoveringNext ? 0.9 : 1))
                )
                .shadow(color: stage.tint.opacity(0.3), radius: hoveringNext ? 16 : 9, y: hoveringNext ? 7 : 4)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.return, modifiers: [])
            .onHover { hoveringNext = $0 }
            .animation(Motion.state, value: hoveringNext)
        }
        .animation(Motion.snappy, value: index)
    }

    // MARK: Actions

    private func next() {
        if isLast { complete() }
        else { withAnimation(Motion.reveal) { tour.currentStep = index + 1 } }
    }

    private func back() {
        guard !isFirst else { return }
        withAnimation(Motion.reveal) { tour.currentStep = index - 1 }
    }

    private func goto(_ i: Int) {
        withAnimation(Motion.reveal) { tour.currentStep = i }
    }

    private func complete() {
        withAnimation(Motion.reveal) { tour.complete() }
    }
}

// MARK: - Backdrop

private struct Backdrop: View {
    let tint: Color
    @Environment(\.palette) private var p

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            LinearGradient(
                colors: [
                    p.background.color.opacity(0.82),
                    tint.opacity(0.12),
                    p.background.color.opacity(0.9)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Circle()
                .fill(tint.opacity(0.18))
                .blur(radius: 90)
                .frame(width: 360, height: 360)
                .offset(x: -360, y: -200)

            Circle()
                .fill(p.accent.color.opacity(0.14))
                .blur(radius: 100)
                .frame(width: 380, height: 380)
                .offset(x: 380, y: 220)
        }
        .ignoresSafeArea()
        .animation(Motion.reveal, value: tint)
    }
}

// MARK: - Small components

private struct StepCounter: View {
    let current: Int
    let total: Int
    @Environment(\.palette) private var p

    var body: some View {
        Text("\(String(format: "%02d", current)) / \(String(format: "%02d", total))")
            .font(Typography.ui(11, weight: .bold))
            .tracking(1.4)
            .foregroundStyle(p.mutedForeground.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(p.background.color.opacity(0.45)))
            .overlay(Capsule().strokeBorder(p.border.color.opacity(0.45), lineWidth: 1))
    }
}

private struct ProgressTrack: View {
    let progress: CGFloat
    let tint: Color
    @Environment(\.palette) private var p

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(p.foreground.color.opacity(0.08))
                Capsule()
                    .fill(LinearGradient(colors: [tint.opacity(0.7), tint], startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(8, geo.size.width * progress))
            }
        }
        .frame(height: 4)
        .animation(Motion.snappy, value: progress)
    }
}

private struct StepDots: View {
    let count: Int
    let index: Int
    let tint: Color
    let onTap: (Int) -> Void
    @Environment(\.palette) private var p

    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<count, id: \.self) { i in
                Button { onTap(i) } label: {
                    Capsule()
                        .fill(i == index ? tint : p.foreground.color.opacity(0.18))
                        .frame(width: i == index ? 22 : 7, height: 7)
                }
                .buttonStyle(.plain)
            }
        }
        .animation(Motion.snappy, value: index)
    }
}

private struct FeatureRow: View {
    let point: OnboardingPoint
    let tint: Color
    @Environment(\.palette) private var p

    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: point.icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(tint.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(point.title)
                    .font(Typography.ui(14, weight: .semibold))
                    .foregroundStyle(p.foreground.color)
                Text(point.text)
                    .font(Typography.ui(12.5, weight: .regular))
                    .foregroundStyle(p.mutedForeground.color)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Stage preview (right-side mock)

private struct StagePreview: View {
    let stage: OnboardingStage
    @Environment(\.palette) private var p

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(p.background.color.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(p.border.color.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 22, y: 14)

            Group {
                switch stage.kind {
                case .welcome:    WelcomeMock(tint: stage.tint)
                case .assistant:  AssistantMock(tint: stage.tint)
                case .sidebar:    SidebarMock(tint: stage.tint)
                case .theme:      ThemeMock(tint: stage.tint)
                case .privacy:    PrivacyMock(tint: stage.tint)
                case .ready:      ReadyMock(tint: stage.tint)
                }
            }
            .padding(22)
        }
    }
}

private struct WelcomeMock: View {
    let tint: Color
    @Environment(\.palette) private var p
    var body: some View {
        VStack(spacing: 22) {
            ZStack {
                Circle().strokeBorder(tint.opacity(0.12), lineWidth: 1).frame(width: 176, height: 176)
                Circle().strokeBorder(tint.opacity(0.2), lineWidth: 1).frame(width: 132, height: 132)
                Circle().fill(tint.opacity(0.14)).frame(width: 96, height: 96)
                Image(systemName: "sparkles")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(tint)
            }
            HStack(spacing: 8) {
                Stat(value: "Local", label: "AI")
                Stat(value: "Zero", label: "tracking")
                Stat(value: "Fast", label: "native")
            }
        }
    }

    private struct Stat: View {
        let value: String; let label: String
        @Environment(\.palette) private var p
        var body: some View {
            VStack(spacing: 2) {
                Text(value).font(Typography.ui(13, weight: .bold)).foregroundStyle(p.foreground.color)
                Text(label).font(Typography.ui(10, weight: .medium)).foregroundStyle(p.mutedForeground.color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(p.card.color.opacity(0.6)))
        }
    }
}

private struct AssistantMock: View {
    let tint: Color
    @Environment(\.palette) private var p
    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 8) {
                Image(systemName: "brain").font(.system(size: 15, weight: .semibold)).foregroundStyle(tint)
                Text("Assistant").font(Typography.ui(13, weight: .semibold)).foregroundStyle(p.foreground.color)
                Spacer()
                ShortcutTag(text: "⌘J")
            }
            Bubble(text: "Summarize this page.", active: false, tint: tint)
            Bubble(text: "4 key points · 2 trackers found · 1 risky redirect.", active: true, tint: tint)
            HStack(spacing: 8) {
                Pill(icon: "doc.text.magnifyingglass", title: "Summarize", tint: tint)
                Pill(icon: "wand.and.stars", title: "Act", tint: tint)
            }
        }
    }

    private struct Bubble: View {
        let text: String; let active: Bool; let tint: Color
        @Environment(\.palette) private var p
        var body: some View {
            Text(text)
                .font(Typography.ui(12, weight: active ? .semibold : .regular))
                .foregroundStyle(active ? p.foreground.color : p.mutedForeground.color)
                .lineSpacing(2)
                .padding(11)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(active ? tint.opacity(0.12) : p.card.color.opacity(0.6)))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(active ? tint.opacity(0.22) : p.border.color.opacity(0.35), lineWidth: 1))
        }
    }
}

private struct SidebarMock: View {
    let tint: Color
    @Environment(\.palette) private var p
    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 9) {
                ForEach(["house", "brain", "shield", "gearshape"], id: \.self) { icon in
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(icon == "brain" ? tint : p.mutedForeground.color)
                        .frame(width: 30, height: 30)
                        .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(icon == "brain" ? tint.opacity(0.14) : p.card.color.opacity(0.6)))
                }
                Spacer(minLength: 0)
            }
            VStack(spacing: 9) {
                Tab(title: "Research", sub: "7 tabs", tint: tint, active: true)
                Tab(title: "Build", sub: "3 tabs", tint: tint, active: false)
                Tab(title: "Reading", sub: "5 tabs", tint: tint, active: false)
                Spacer(minLength: 0)
            }
        }
    }

    private struct Tab: View {
        let title: String; let sub: String; let tint: Color; let active: Bool
        @Environment(\.palette) private var p
        var body: some View {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(active ? tint : p.mutedForeground.color.opacity(0.2)).frame(width: 26, height: 26)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(Typography.ui(12.5, weight: .semibold)).foregroundStyle(p.foreground.color)
                    Text(sub).font(Typography.ui(10.5, weight: .medium)).foregroundStyle(p.mutedForeground.color)
                }
                Spacer(minLength: 0)
            }
            .padding(9)
            .background(RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(active ? tint.opacity(0.1) : p.card.color.opacity(0.5)))
        }
    }
}

private struct ThemeMock: View {
    let tint: Color
    @Environment(\.palette) private var p
    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 9) {
                ForEach([tint, p.primary.color, p.accent.color, p.muted.color], id: \.self) { c in
                    RoundedRectangle(cornerRadius: 12, style: .continuous).fill(c.opacity(0.85)).frame(height: 64)
                }
            }
            VStack(spacing: 9) {
                Slider(width: 0.74, tint: tint)
                Slider(width: 0.5, tint: p.primary.color)
                Slider(width: 0.86, tint: p.accent.color)
            }
            HStack(spacing: 8) {
                Pill(icon: "paintbrush", title: "OKLCH", tint: tint)
                Pill(icon: "moon.stars", title: "Adaptive", tint: tint)
            }
        }
    }

    private struct Slider: View {
        let width: CGFloat; let tint: Color
        @Environment(\.palette) private var p
        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(p.foreground.color.opacity(0.08))
                    Capsule().fill(tint.opacity(0.8)).frame(width: geo.size.width * width)
                }
            }
            .frame(height: 7)
        }
    }
}

private struct PrivacyMock: View {
    let tint: Color
    @Environment(\.palette) private var p
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(tint.opacity(0.14)).frame(width: 96, height: 96)
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 38, weight: .regular)).foregroundStyle(tint)
            }
            VStack(spacing: 8) {
                Row(title: "Trackers blocked", value: "128", tint: tint)
                Row(title: "Fingerprint noise", value: "On", tint: tint)
                Row(title: "Local assistant", value: "Private", tint: tint)
            }
        }
    }

    private struct Row: View {
        let title: String; let value: String; let tint: Color
        @Environment(\.palette) private var p
        var body: some View {
            HStack {
                Text(title).font(Typography.ui(12.5, weight: .medium)).foregroundStyle(p.mutedForeground.color)
                Spacer()
                Text(value).font(Typography.ui(12.5, weight: .bold)).foregroundStyle(tint)
            }
            .padding(.horizontal, 12).padding(.vertical, 9)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(p.card.color.opacity(0.6)))
        }
    }
}

private struct ReadyMock: View {
    let tint: Color
    @Environment(\.palette) private var p
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(tint.opacity(0.14)).frame(width: 132, height: 96)
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 44, weight: .regular)).foregroundStyle(tint)
            }
            VStack(spacing: 8) {
                Shortcut(keys: "⌘L", action: "Search")
                Shortcut(keys: "⌘K", action: "Command menu")
                Shortcut(keys: "⌘J", action: "Ask the assistant")
            }
        }
    }

    private struct Shortcut: View {
        let keys: String; let action: String
        @Environment(\.palette) private var p
        var body: some View {
            HStack {
                Text(keys).font(Typography.ui(12, weight: .bold)).foregroundStyle(p.foreground.color)
                    .frame(width: 38, alignment: .leading)
                Text(action).font(Typography.ui(12.5, weight: .medium)).foregroundStyle(p.mutedForeground.color)
                Spacer()
            }
            .padding(.horizontal, 12).padding(.vertical, 9)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(p.card.color.opacity(0.6)))
        }
    }
}

private struct Pill: View {
    let icon: String; let title: String; let tint: Color
    @Environment(\.palette) private var p
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 11, weight: .semibold)).foregroundStyle(tint)
            Text(title).font(Typography.ui(11, weight: .semibold)).foregroundStyle(p.foreground.color)
        }
        .padding(.horizontal, 11).padding(.vertical, 7)
        .background(Capsule().fill(p.card.color.opacity(0.7)))
    }
}

private struct ShortcutTag: View {
    let text: String
    @Environment(\.palette) private var p
    var body: some View {
        Text(text)
            .font(Typography.ui(11, weight: .bold))
            .foregroundStyle(p.foreground.color)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(p.card.color.opacity(0.7)))
            .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).strokeBorder(p.border.color.opacity(0.4), lineWidth: 1))
    }
}

// MARK: - Stage model

private struct OnboardingPoint: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let text: String
}

private struct OnboardingStage: Identifiable {
    enum Kind { case welcome, assistant, sidebar, theme, privacy, ready }

    let id = UUID()
    let kind: Kind
    let eyebrow: String
    let title: String
    let body: String
    let tint: Color
    let points: [OnboardingPoint]

    static let all: [OnboardingStage] = [
        OnboardingStage(
            kind: .welcome,
            eyebrow: "Welcome",
            title: "A calmer, smarter way to browse.",
            body: "Soul is a native Mac browser built around focus, privacy, and on-device intelligence.",
            tint: Color(red: 0.55, green: 0.42, blue: 1.0),
            points: [
                OnboardingPoint(icon: "sparkles", title: "Local-first", text: "Your AI and data stay on your Mac."),
                OnboardingPoint(icon: "bolt.fill", title: "Fast & native", text: "Built on Chromium with a SwiftUI shell."),
                OnboardingPoint(icon: "square.grid.2x2.fill", title: "Designed", text: "A consistent, intentional interface.")
            ]
        ),
        OnboardingStage(
            kind: .assistant,
            eyebrow: "Assistant",
            title: "Ask your browser about any page.",
            body: "Press ⌘J to summarize, extract key points, and turn what you read into action.",
            tint: Color(red: 0.2, green: 0.56, blue: 1.0),
            points: [
                OnboardingPoint(icon: "doc.text.magnifyingglass", title: "Summaries", text: "Understand long pages in seconds."),
                OnboardingPoint(icon: "checklist", title: "Key points", text: "Pull claims, links, and risks fast."),
                OnboardingPoint(icon: "lock.fill", title: "Private", text: "Designed for on-device intelligence.")
            ]
        ),
        OnboardingStage(
            kind: .sidebar,
            eyebrow: "Spaces",
            title: "Tabs that stay organized.",
            body: "Group work into spaces and pinned flows so you can pick up exactly where you left off.",
            tint: Color(red: 0.16, green: 0.76, blue: 0.6),
            points: [
                OnboardingPoint(icon: "sidebar.left", title: "Workspaces", text: "Keep related tabs together."),
                OnboardingPoint(icon: "pin.fill", title: "Pinned grids", text: "Stable homes for daily tools."),
                OnboardingPoint(icon: "wand.and.stars", title: "Auto-group", text: "Let Soul tidy messy sessions.")
            ]
        ),
        OnboardingStage(
            kind: .theme,
            eyebrow: "Appearance",
            title: "Make it feel like yours.",
            body: "Pick refined gradient presets or craft your own palette — everything stays readable.",
            tint: Color(red: 0.94, green: 0.46, blue: 0.78),
            points: [
                OnboardingPoint(icon: "paintbrush.fill", title: "Themes", text: "From subtle graphite to vivid moods."),
                OnboardingPoint(icon: "circle.hexagongrid.fill", title: "Tokens", text: "Coherent type, color, and motion."),
                OnboardingPoint(icon: "moon.stars.fill", title: "Adaptive", text: "Tuned for light and dark.")
            ]
        ),
        OnboardingStage(
            kind: .privacy,
            eyebrow: "Privacy",
            title: "Protection you can actually see.",
            body: "Tracker blocking, fingerprint defense, and private sessions are built into the browser.",
            tint: Color(red: 0.2, green: 0.72, blue: 0.36),
            points: [
                OnboardingPoint(icon: "checkmark.shield.fill", title: "Blocking", text: "Cut cross-site trackers."),
                OnboardingPoint(icon: "eye.slash.fill", title: "Anti-fingerprint", text: "Reduce silent tracking."),
                OnboardingPoint(icon: "lock.square.fill", title: "Private sessions", text: "Isolate sensitive browsing.")
            ]
        ),
        OnboardingStage(
            kind: .ready,
            eyebrow: "All set",
            title: "You're ready to go.",
            body: "Three shortcuts cover the essentials. Everything else you'll discover as you browse.",
            tint: Color(red: 1.0, green: 0.57, blue: 0.21),
            points: [
                OnboardingPoint(icon: "magnifyingglass", title: "⌘L", text: "Search from the address bar."),
                OnboardingPoint(icon: "command", title: "⌘K", text: "Open the command menu."),
                OnboardingPoint(icon: "brain", title: "⌘J", text: "Ask the assistant anything.")
            ]
        )
    ]
}
