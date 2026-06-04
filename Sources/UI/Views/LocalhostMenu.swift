import SwiftUI

struct LocalhostMenu: View {
    @ObservedObject var tab: BrowserTab
    @ObservedObject var store: BrowserStore
    @StateObject private var scanner = LocalhostScanner()
    @State private var isHovering = false
    @Environment(\.palette) private var p
    
    var body: some View {
        Menu {
            if scanner.activeServers.isEmpty {
                if scanner.isScanning {
                    Text("Scanning ports...")
                } else {
                    Text("No local servers found")
                }
            } else {
                Text("Local Development Servers")
                
                ForEach(scanner.activeServers) { server in
                    Button {
                        store.navigate(server.urlString)
                    } label: {
                        HStack {
                            Text("\(server.command) (:\(server.port))")
                            Spacer()
                        }
                    }
                }
            }
            
            Divider()
            
            Button("Rescan Ports") {
                scanner.scan()
            }
        } label: {
            Icon(name: "terminal.fill", size: 13, weight: .regular)
                .foregroundStyle(scanner.activeServers.isEmpty ? p.mutedForeground.color : p.statusSuccessFg.color)
                .padding(.horizontal, 6)
                .frame(height: 22)
                .background(
                    Capsule().fill(isHovering ? p.mutedForeground.color.opacity(0.1) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .onHover { hover in
            isHovering = hover
            if hover {
                // Auto rescan when hovering over the button
                scanner.scan()
            }
        }
    }
}
