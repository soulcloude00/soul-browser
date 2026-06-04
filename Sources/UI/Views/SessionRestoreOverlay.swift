import SwiftUI

/// Modal dialog shown on launch when a crash was detected on the previous
/// session. Lets the user restore their tabs or start fresh.
struct SessionRestoreOverlay: View {
    @ObservedObject var store: BrowserStore
    @Environment(\.palette) private var p

    var body: some View {
        ZStack {
            p.background.color.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(p.statusWarningFg.color)

                Text("Restore Previous Session?")
                    .font(Typography.ui(18, weight: .semibold))
                    .foregroundStyle(p.foreground.color)

                Text("Soul closed unexpectedly. \(store.sessionResumption.lastSessionTabs.count) tab(s) were open.")
                    .font(Typography.ui(Typography.base))
                    .foregroundStyle(p.mutedForeground.color)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 320)

                HStack(spacing: 12) {
                    Button {
                        store.sessionResumption.detectedCrash = false
                        store.sessionResumption.markSessionCleanExit()
                    } label: {
                        Text("Start Fresh")
                            .font(Typography.ui(Typography.base, weight: .medium))
                            .foregroundStyle(p.foreground.color)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
                                    .fill(p.card.color)
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        store.sessionResumption.restoreTo(store: store)
                    } label: {
                        Text("Restore Session")
                            .font(Typography.ui(Typography.base, weight: .semibold))
                            .foregroundStyle(p.primaryForeground.color)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
                                    .fill(p.primary.color)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: 340)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: Radius.window, style: .continuous)
                    .fill(p.popover.color)
                    .shadow(color: Color.black.opacity(0.25), radius: 40, x: 0, y: 20)
            )
        }
    }
}
