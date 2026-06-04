import SwiftUI

struct WorkspaceManagerView: View {
    @ObservedObject var store: BrowserStore
    @Environment(\.palette) private var p
    @Environment(\.dismiss) private var dismiss

    @State private var selectedWorkspaceID: String = ""
    @State private var name: String = ""
    @State private var emoji: String = "✦"
    @State private var colorHex: String = "#5b21b6"

    private let colors = [
        "#5b21b6", // Violet
        "#7c3aed", // Purple
        "#3b82f6", // Blue
        "#06b6d4", // Cyan
        "#10b981", // Emerald
        "#f59e0b", // Amber
        "#ef4444", // Red
        "#ec4899"  // Pink
    ]

    private let emojis = ["✦", "💼", "🏠", "🎓", "🎮", "🎨", "🚀", "🍿", "🧪", "🔍", "💬", "🌍"]

    var body: some View {
        VStack(spacing: 16) {
            Text("Workspaces")
                .font(Typography.ui(Typography.title, weight: .bold))
                .foregroundStyle(p.foreground.color)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .top, spacing: 16) {
                // Left List of workspaces
                VStack(spacing: 6) {
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(store.availableWorkspaces) { ws in
                                WorkspaceRowItem(ws: ws, isSelected: ws.id == selectedWorkspaceID) {
                                    selectWorkspace(ws)
                                }
                            }
                        }
                    }
                    .frame(width: 140, height: 160)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                            .fill(p.sidebar.color.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: Radius.md)
                                    .stroke(p.border.color, lineWidth: 1)
                            )
                    )

                    Button(action: addWorkspace) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Space")
                        }
                        .font(Typography.ui(Typography.base, weight: .medium))
                        .foregroundStyle(p.primary.color)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.sm)
                                .fill(p.primary.color.opacity(0.1))
                        )
                    }
                    .buttonStyle(.plain)
                }

                // Right Editor
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Name")
                            .font(Typography.ui(Typography.small, weight: .semibold))
                            .foregroundStyle(p.mutedForeground.color)
                        TextField("Workspace Name", text: $name)
                            .textFieldStyle(.roundedBorder)
                            .font(Typography.ui(Typography.base))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Icon / Emoji")
                            .font(Typography.ui(Typography.small, weight: .semibold))
                            .foregroundStyle(p.mutedForeground.color)
                        
                        HStack(spacing: 4) {
                            TextField("", text: $emoji)
                                .frame(width: 32)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.center)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 4) {
                                    ForEach(emojis, id: \.self) { em in
                                        Button(em) {
                                            self.emoji = em
                                        }
                                        .font(.system(size: 16))
                                        .buttonStyle(.plain)
                                        .frame(width: 24, height: 24)
                                        .background(self.emoji == em ? p.primary.color.opacity(0.15) : Color.clear)
                                        .clipShape(Circle())
                                    }
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Accent Color")
                            .font(Typography.ui(Typography.small, weight: .semibold))
                            .foregroundStyle(p.mutedForeground.color)
                        
                        HStack(spacing: 6) {
                            ForEach(colors, id: \.self) { hex in
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .stroke(p.foreground.color, lineWidth: self.colorHex == hex ? 2 : 0)
                                    )
                                    .onTapGesture {
                                        self.colorHex = hex
                                    }
                            }
                        }
                    }

                    Spacer(minLength: 0)

                    HStack(spacing: 8) {
                        if store.availableWorkspaces.count > 1 {
                            Button("Delete", role: .destructive) {
                                store.deleteWorkspace(id: selectedWorkspaceID)
                                if let first = store.availableWorkspaces.first {
                                    selectWorkspace(first)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }

                        Spacer()

                        Button("Save") {
                            store.updateWorkspace(id: selectedWorkspaceID, name: name, icon: emoji, colorHex: colorHex)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(p.primary.color)
                    }
                }
                .frame(width: 220)
            }
        }
        .padding(16)
        .frame(width: 400, height: 260)
        .onAppear {
            if let first = store.availableWorkspaces.first(where: { $0.id == store.activeWorkspaceId }) ?? store.availableWorkspaces.first {
                selectWorkspace(first)
            }
        }
    }

    private func selectWorkspace(_ ws: Workspace) {
        selectedWorkspaceID = ws.id
        name = ws.name
        emoji = ws.icon
        colorHex = ws.colorHex ?? "#5b21b6"
    }

    private func addWorkspace() {
        store.addWorkspace(name: "New Space", icon: "✦", colorHex: "#5b21b6")
        if let last = store.availableWorkspaces.last {
            selectWorkspace(last)
        }
    }
}

private struct WorkspaceRowItem: View {
    let ws: Workspace
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.palette) private var p
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(ws.icon)
                Text(ws.name)
                    .font(Typography.ui(Typography.base, weight: .medium))
                    .lineLimit(1)
                Spacer()
                if let hex = ws.colorHex {
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(isSelected ? p.primary.color.opacity(0.15) : (hovering ? p.foreground.color.opacity(0.05) : Color.clear))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
