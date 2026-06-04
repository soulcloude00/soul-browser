import SwiftUI

struct MiniConsoleView: View {
    @ObservedObject var tab: BrowserTab
    @ObservedObject var store: BrowserStore
    @Environment(\.palette) private var p
    @State private var filterQuery: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Toolbar
            HStack(spacing: 12) {
                Text("Mini Console")
                    .font(Typography.ui(Typography.small, weight: .semibold))
                    .foregroundStyle(p.primary.color)
                
                Spacer()
                
                HStack(spacing: 8) {
                    TextField("Filter...", text: $filterQuery)
                        .textFieldStyle(.plain)
                        .font(Typography.ui(Typography.small))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(p.foreground.color.opacity(0.05))
                        .cornerRadius(6)
                        .frame(width: 150)
                    
                    Button {
                        tab.consoleLogs.removeAll()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundStyle(p.foreground.color.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                    .help("Clear Console")
                    
                    Button {
                        withAnimation(Motion.state) {
                            store.miniConsoleVisible = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12))
                            .foregroundStyle(p.foreground.color.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                    .help("Close Console")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Rectangle()
                    .fill(p.popover.color)
                    .background(VisualEffectBackground(material: .popover))
            )
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(p.border.color),
                alignment: .bottom
            )
            
            // Log List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        let filtered = filterQuery.isEmpty ? tab.consoleLogs : tab.consoleLogs.filter { $0.message.localizedCaseInsensitiveContains(filterQuery) }
                        
                        ForEach(filtered) { log in
                            LogMessageRow(log: log)
                                .id(log.id)
                        }
                    }
                    .padding(8)
                }
                .onChange(of: tab.consoleLogs.count) { _, _ in
                    if let lastId = tab.consoleLogs.last?.id {
                        withAnimation(.easeOut(duration: 0.15)) {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            .background(p.background.color)
        }
        .frame(height: 250)
        .background(p.background.color)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(p.border.color),
            alignment: .top
        )
    }
}

struct LogMessageRow: View {
    let log: LogMessage
    @Environment(\.palette) private var p
    
    // CEF log levels: 0=Default, 1=Verbose/Debug, 2=Info, 3=Warning, 4=Error, 5=Fatal
    private var isWarning: Bool { log.level == 3 }
    private var isError: Bool { log.level >= 4 }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Severity icon
            Group {
                if isError {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.red)
                } else if isWarning {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.orange)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.blue)
                }
            }
            .font(.system(size: 10, weight: .bold))
            .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(log.message)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(p.primary.color)
                    .textSelection(.enabled)
                
                if !log.source.isEmpty {
                    Text("\(log.source):\(log.line)")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(p.foreground.color.opacity(0.4))
                }
            }
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isError ? Color.red.opacity(0.08) : (isWarning ? Color.orange.opacity(0.08) : Color.clear))
        )
    }
}
