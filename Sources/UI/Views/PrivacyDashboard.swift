import SwiftUI

struct PrivacyDashboardPopover: View {
    @ObservedObject var tab: BrowserTab
    @Environment(\.palette) private var p
    @ObservedObject private var settings = BrowserSettings.shared
    
    private var isException: Bool {
        guard let host = host else { return false }
        return settings.adBlockExceptions.contains(host)
    }
    
    private var host: String? {
        URL(string: tab.urlString)?.host?.lowercased()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Icon(name: "shield.fill", size: 18)
                    .foregroundStyle(isException ? p.mutedForeground.color : p.accent.color)
                Text("Privacy Shields")
                    .font(Typography.ui(Typography.base, weight: .semibold))
                    .foregroundStyle(p.foreground.color)
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { !isException },
                    set: { enabled in
                        guard let host = host else { return }
                        if enabled {
                            settings.adBlockExceptions.remove(host)
                        } else {
                            settings.adBlockExceptions.insert(host)
                        }
                        tab.reload()
                    }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
                .tint(p.accent.color)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Hairline()
            
            // Stats
            VStack(spacing: 4) {
                Text("\(tab.blockedTrackers.count)")
                    .font(Typography.ui(36, weight: .bold))
                    .foregroundStyle(isException ? p.mutedForeground.color : p.accent.color)
                Text("Trackers Blocked")
                    .font(Typography.ui(Typography.small, weight: .medium))
                    .foregroundStyle(p.mutedForeground.color)
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            
            // List
            if !tab.blockedTrackers.isEmpty {
                Hairline()
                
                DisclosureGroup {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(Array(tab.blockedTrackers).sorted(), id: \.self) { trackerHost in
                                HStack {
                                    Icon(name: "xmark.shield.fill", size: 10)
                                        .foregroundStyle(p.statusWarningFg.color.opacity(0.8))
                                    Text(trackerHost)
                                        .font(Typography.ui(Typography.small))
                                        .foregroundStyle(p.mutedForeground.color)
                                        .lineLimit(1)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 150)
                } label: {
                    Text("View Blocked Domains")
                        .font(Typography.ui(Typography.small, weight: .medium))
                        .foregroundStyle(p.foreground.color)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .tint(p.mutedForeground.color)
            }
        }
        .frame(width: 280)
        .background(p.popover.color)
    }
}
