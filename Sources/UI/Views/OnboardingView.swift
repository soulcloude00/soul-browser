import SwiftUI

// MARK: - Onboarding
struct OnboardingView: View {
    @ObservedObject var tour: OnboardingTour
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Background Gradient (Helium style)
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(hex: "#170F2E"), Color(hex: "#2D1B4E")]
                    : [Color(hex: "#FAF5FF"), Color(hex: "#FDF2F8")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Content area
                Group {
                    switch OnboardingTour.Step(rawValue: tour.currentStep) ?? .welcome {
                    case .welcome: HeliumWelcomeView(tour: tour)
                    case .services: HeliumServicesView(tour: tour)
                    case .searchEngine: HeliumSearchEngineView(tour: tour)
                    case .dataImport: HeliumDataImportView(tour: tour)
                    case .defaultBrowser: HeliumDefaultBrowserView(tour: tour)
                    case .finish: HeliumFinishView(tour: tour)
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .bottom).animation(.easeOut(duration: 0.25))),
                    removal: .opacity.combined(with: .move(edge: .top).animation(.easeOut(duration: 0.25)))
                ))
                .id(tour.currentStep)

                Spacer()

                // Bottom Navigation (hidden on Welcome and Finish)
                if tour.currentStep > 0 && tour.currentStep < OnboardingTour.Step.finish.rawValue {
                    HeliumPageNavigation(tour: tour)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onExitCommand { tour.complete() }
    }
}

// MARK: - Helium Views

struct HeliumWelcomeView: View {
    @ObservedObject var tour: OnboardingTour
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Icon(name: "soul", size: 64, weight: .regular)
                    .foregroundStyle(LinearGradient(colors: [Color(hex: "#8B5CF6"), Color(hex: "#EC4899")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 64, height: 64)
                    .shadow(color: Color(hex: "#8B5CF6").opacity(0.3), radius: 10, y: 5)

                VStack(spacing: 16) {
                    Text("Meet Soul")
                        .font(.system(size: 48, weight: .medium, design: .default))
                        .tracking(-0.5)
                        .foregroundStyle(primaryColor)

                    Text("Configure your browser just the way you want it, or use\nthe default preset with best privacy and comfort.")
                        .font(.system(size: 20, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(secondaryColor)
                        .lineSpacing(4)
                }
            }
            .frame(maxWidth: 600)

            HStack(spacing: 16) {
                Button(action: {
                    tour.complete()
                }) {
                    HStack(spacing: 9) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .medium))
                        Text("Use defaults")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                .buttonStyle(HeliumSecondaryButtonStyle())

                Button(action: {
                    tour.nextStep()
                }) {
                    HStack(spacing: 9) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                        Text("Configure")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .buttonStyle(HeliumPrimaryButtonStyle())
            }
            
            VStack(spacing: 6) {
                Text("By continuing, you agree to the privacy policy and terms of use.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(secondaryColor)
                Text("You can skip setup and come back later, but Soul services won't work without it.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(secondaryColor)
            }
            .padding(.top, 40)
        }
    }

    private var primaryColor: Color {
        colorScheme == .dark ? Color(hex: "#F5F3FF") : Color(hex: "#2E1065")
    }

    private var secondaryColor: Color {
        colorScheme == .dark ? Color(hex: "#C4B5FD") : Color(hex: "#5B21B6")
    }

    private func elevatedColor(opacity: Double) -> Color {
        colorScheme == .dark
            ? Color(hex: "#A78BFA").opacity(opacity)
            : Color(hex: "#7C3AED").opacity(opacity)
    }
}

// A reusable header for pages
struct HeliumPageHeader: View {
    let title: String
    let subtitle: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 12) {
            Icon(name: "soul", size: 48, weight: .regular)
                .foregroundStyle(LinearGradient(colors: [Color(hex: "#8B5CF6"), Color(hex: "#EC4899")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 48, height: 48)
                .shadow(color: Color(hex: "#8B5CF6").opacity(0.3), radius: 8, y: 4)
            
            Text(title)
                .font(.system(size: 32, weight: .medium))
                .tracking(-0.5)
                .foregroundStyle(primaryColor)

            Text(subtitle)
                .font(.system(size: 16, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundStyle(secondaryColor)
                .lineSpacing(2)
        }
    }

    private var primaryColor: Color {
        colorScheme == .dark ? Color(hex: "#F5F3FF") : Color(hex: "#2E1065")
    }
    private var secondaryColor: Color {
        colorScheme == .dark ? Color(hex: "#C4B5FD") : Color(hex: "#5B21B6")
    }
}

struct HeliumServicesView: View {
    @ObservedObject var tour: OnboardingTour
    @State private var s1 = true
    @State private var s2 = true
    @State private var s3 = true
    @State private var s4 = true

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                HeliumPageHeader(
                    title: "Soul services",
                    subtitle: "Services are not active until you consent to using them.\nChanges will be applied after you go to the next page."
                )

                VStack(spacing: 12) {
                    HeliumToggle(title: "Allow connecting to Soul services", desc: "Soul services provide additional functionality, such as extension downloads, updates, and more.", isOn: $s1)
                    Divider().padding(.vertical, 8)
                    HeliumToggle(title: "Proxy extension downloads and updates", desc: "When enabled, Soul will proxy extension downloads and updates to protect your privacy.", isOn: $s2)
                    HeliumToggle(title: "Allow downloading filter lists for adblocker", desc: "Soul will fetch fresh filter lists. All requests are proxied.", isOn: $s3)
                    HeliumToggle(title: "Allow automatic browser updates", desc: "Soul will automatically check for updates and install them. Recommended.", isOn: $s4)
                }
                .frame(maxWidth: 600)
                .padding(.horizontal, 6)
            }
            .padding(.bottom, 96)
        }
    }
}

struct HeliumSearchEngineView: View {
    @ObservedObject var tour: OnboardingTour
    @State private var selectedEngine = "DuckDuckGo"

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                HeliumPageHeader(
                    title: "Default search engine",
                    subtitle: "You can change your choice later in Settings.\nEngines are ordered by privacy."
                )

                VStack(spacing: 12) {
                    HeliumEngineCard(name: "DuckDuckGo", desc: "Privacy-focused. Relies on Bing results but promises to never track or profile you.", isSelected: selectedEngine == "DuckDuckGo") {
                        selectedEngine = "DuckDuckGo"
                    }
                    HeliumEngineCard(name: "Kagi", desc: "Privacy-focused. Customizable results without ads or tracking. Requires a paid account.", isSelected: selectedEngine == "Kagi") {
                        selectedEngine = "Kagi"
                    }
                    HeliumEngineCard(name: "Google", desc: "It's Google. It dominates the search market, collects extensive personal data, and profiles you.", isSelected: selectedEngine == "Google") {
                        selectedEngine = "Google"
                    }
                }
                .frame(maxWidth: 600)
                .padding(.horizontal, 6)
            }
            .padding(.bottom, 96)
        }
    }
}

struct HeliumDataImportView: View {
    @ObservedObject var tour: OnboardingTour
    @State private var importBookmarks = true
    @State private var importHistory = true
    @State private var importExtensions = true

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                HeliumPageHeader(
                    title: "Take your stuff with you",
                    subtitle: "Transfer your most important bookmarks, history,\nand extensions from other browsers."
                )

                VStack(spacing: 12) {
                    HeliumToggle(title: "Bookmarks", desc: "Import from Safari and Chrome.", isOn: $importBookmarks)
                    HeliumToggle(title: "History", desc: "Import recent browsing history.", isOn: $importHistory)
                    HeliumToggle(title: "Extensions", desc: "Import installed extensions.", isOn: $importExtensions)
                }
                .frame(maxWidth: 600)
                .padding(.horizontal, 6)
            }
            .padding(.bottom, 96)
        }
    }
}

struct HeliumDefaultBrowserView: View {
    @ObservedObject var tour: OnboardingTour
    @State private var selectedOption = "Yes"

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                HeliumPageHeader(
                    title: "Ready to switch to Soul?",
                    subtitle: "Better privacy, speed, and comfort. All in one click.\nLet's make links open in Soul by default."
                )

                VStack(spacing: 12) {
                    HeliumEngineCard(name: "Yes", desc: "Make Soul my default browser.", isSelected: selectedOption == "Yes") {
                        selectedOption = "Yes"
                    }
                    HeliumEngineCard(name: "No", desc: "Just trying Soul for now.", isSelected: selectedOption == "No") {
                        selectedOption = "No"
                    }
                }
                .frame(maxWidth: 600)
                .padding(.horizontal, 6)
            }
            .padding(.bottom, 96)
        }
    }
}

struct HeliumFinishView: View {
    @ObservedObject var tour: OnboardingTour
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Icon(name: "soul", size: 64, weight: .regular)
                    .foregroundStyle(LinearGradient(colors: [Color(hex: "#8B5CF6"), Color(hex: "#EC4899")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 64, height: 64)
                    .shadow(color: Color(hex: "#8B5CF6").opacity(0.3), radius: 10, y: 5)

                VStack(spacing: 16) {
                    Text("Ready to browse?")
                        .font(.system(size: 48, weight: .medium))
                        .tracking(-0.5)
                        .foregroundStyle(primaryColor)

                    Text("The setup is complete, thank you for choosing Soul.\nTime to enjoy the Internet again.")
                        .font(.system(size: 20, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(secondaryColor)
                        .lineSpacing(4)
                }
            }
            .frame(maxWidth: 600)

            Button(action: {
                tour.complete()
            }) {
                HStack(spacing: 9) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .bold))
                    Text("Let's go!")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .buttonStyle(HeliumPrimaryButtonStyle())
        }
    }

    private var primaryColor: Color {
        colorScheme == .dark ? Color(hex: "#F5F3FF") : Color(hex: "#2E1065")
    }
    private var secondaryColor: Color {
        colorScheme == .dark ? Color(hex: "#C4B5FD") : Color(hex: "#5B21B6")
    }
}

struct HeliumPageNavigation: View {
    @ObservedObject var tour: OnboardingTour

    var body: some View {
        HStack(spacing: 16) {
            Button(action: { tour.previousStep() }) {
                HStack(spacing: 9) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .medium))
                    Text("Back")
                        .font(.system(size: 16, weight: .medium))
                }
            }
            .buttonStyle(HeliumSecondaryButtonStyle())
            
            Button(action: { tour.nextStep() }) {
                HStack(spacing: 9) {
                    Text("Next")
                        .font(.system(size: 16, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .buttonStyle(HeliumPrimaryButtonStyle())
        }
        .padding(.bottom, 48)
    }
}

// Components
struct HeliumToggle: View {
    let title: String
    let desc: String
    @Binding var isOn: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(primaryColor)
                Text(desc)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(secondaryColor)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .tint(Color(hex: "#8B5CF6"))
        }
        .padding(.vertical, 8)
    }
    
    private var primaryColor: Color {
        colorScheme == .dark ? Color(hex: "#F5F3FF") : Color(hex: "#2E1065")
    }
    private var secondaryColor: Color {
        colorScheme == .dark ? Color(hex: "#C4B5FD") : Color(hex: "#5B21B6")
    }
}

struct HeliumEngineCard: View {
    let name: String
    let desc: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Circle()
                    .fill(isSelected ? LinearGradient(colors: [Color(hex: "#8B5CF6"), Color(hex: "#EC4899")], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [elevatedColor(opacity: 0.1), elevatedColor(opacity: 0.1)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                            .opacity(isSelected ? 1 : 0)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, y: 1)
                    )
                    .shadow(color: isSelected ? Color(hex: "#EC4899").opacity(0.4) : .clear, radius: 4, y: 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(primaryColor)
                    Text(desc)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(secondaryColor)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(elevatedColor(opacity: isHovered || isSelected ? 0.08 : 0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? Color(hex: "#8B5CF6").opacity(0.8) : elevatedColor(opacity: 0.08), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? Color(hex: "#8B5CF6").opacity(0.15) : .clear, radius: 10, y: 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .scaleEffect(isHovered && !isSelected ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }

    private var primaryColor: Color {
        colorScheme == .dark ? Color(hex: "#F5F3FF") : Color(hex: "#2E1065")
    }
    private var secondaryColor: Color {
        colorScheme == .dark ? Color(hex: "#C4B5FD") : Color(hex: "#5B21B6")
    }
    private func elevatedColor(opacity: Double) -> Color {
        colorScheme == .dark
            ? Color(hex: "#A78BFA").opacity(opacity)
            : Color(hex: "#7C3AED").opacity(opacity)
    }
}

// MARK: - Button Styles

struct HeliumPrimaryButtonStyle: ButtonStyle {
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .foregroundStyle(.white)
            .background(
                Capsule()
                    .fill(LinearGradient(
                        colors: isHovered 
                            ? [Color(hex: "#9333EA"), Color(hex: "#DB2777")]
                            : [Color(hex: "#8B5CF6"), Color(hex: "#EC4899")],
                        startPoint: .leading, endPoint: .trailing
                    ))
            )
            .shadow(color: Color(hex: "#EC4899").opacity(isHovered ? 0.4 : 0.25), radius: isHovered ? 12 : 8, y: isHovered ? 6 : 4)
            .contentShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : (isHovered ? 1.03 : 1.0))
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isHovered)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
            .onHover { isHovered = $0 }
    }
}

struct HeliumSecondaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        let primaryColor = colorScheme == .dark ? Color(hex: "#F5F3FF") : Color(hex: "#2E1065")
        let elevatedColor = colorScheme == .dark 
            ? Color(hex: "#A78BFA")
            : Color(hex: "#7C3AED")
            
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .foregroundStyle(primaryColor)
            .background(
                Capsule()
                    .fill(elevatedColor.opacity(isHovered ? 0.12 : 0.05))
            )
            .overlay(
                Capsule().strokeBorder(elevatedColor.opacity(0.1), lineWidth: 1)
            )
            .contentShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : (isHovered ? 1.02 : 1.0))
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isHovered)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
            .onHover { isHovered = $0 }
    }
}

