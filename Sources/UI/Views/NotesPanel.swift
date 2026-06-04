import SwiftUI

struct NotesPanel: View {
    @ObservedObject var store: BrowserStore
    @Environment(\.palette) private var p
    @Environment(\.colorScheme) private var scheme
    
    @State private var isPreviewMode: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.6)
            
            if isPreviewMode {
                previewContainer
            } else {
                editorContainer
            }
        }
        .frame(width: 320)
        .background(
            Rectangle()
                .fill(Color.black.opacity(0.005))
                .shadow(color: p.accent.color.opacity(0.12), radius: 30, x: -8, y: 0)
                .drawingGroup()
        )

    }
    
    private var header: some View {
        HStack(spacing: 8) {
            Icon(name: "note.text", size: 16)
                .foregroundStyle(.secondary)
            
            Menu {
                ForEach(store.availableNotes, id: \.self) { name in
                    Button(name) {
                        store.switchToNote(name)
                    }
                }
                Divider()
                Button("Create New Note...") {
                    promptNewNote()
                }
                if store.availableNotes.count > 1 {
                    Menu("Delete Note") {
                        ForEach(store.availableNotes, id: \.self) { name in
                            Button(name) {
                                store.deleteNote(name)
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(store.activeNoteName)
                        .font(Typography.ui(14, weight: .semibold))
                        .foregroundStyle(.primary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                        .opacity(0.6)
                }
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            
            Spacer()
            
            // Preview / Edit Toggle
            Button(action: { isPreviewMode.toggle() }) {
                Icon(name: isPreviewMode ? "pencil" : "eye", size: 16)
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(isPreviewMode ? "Edit Notes" : "Preview Markdown")
            
            // Copy Button
            Button(action: copyToClipboard) {
                Icon(name: "doc.on.doc", size: 16)
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Copy to Clipboard")
            
            // Clear Button
            Button(action: clearNotes) {
                Icon(name: "trash", size: 16)
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Clear Notes")
            
            // Close Button
            Button(action: { store.toggleNotesPanel() }) {
                Icon(name: "xmark", size: 16)
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Close Notes")
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
    }

    private func promptNewNote() {
        let alert = NSAlert()
        alert.messageText = "New Scratchpad Note"
        alert.informativeText = "Enter a name for the new note file:"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Create")
        alert.addButton(withTitle: "Cancel")
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        input.stringValue = "Note \(store.availableNotes.count + 1)"
        alert.accessoryView = input
        
        if alert.runModal() == .alertFirstButtonReturn {
            let name = input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !name.isEmpty {
                store.createNewNote(name: name)
            }
        }
    }
    
    private var editorContainer: some View {
        VStack {
            TextEditor(text: $store.notesContent)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(p.foreground.color)
                .scrollContentBackground(.hidden)
                .padding(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(p.sidebar.color.opacity(0.15))
    }
    
    private var previewContainer: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if store.notesContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("*No content to preview. Start writing in Edit Mode!*")
                        .font(Typography.ui(Typography.base))
                        .foregroundStyle(.secondary)
                } else {
                    Text(LocalizedStringKey(store.notesContent))
                        .font(Typography.ui(Typography.base))
                        .foregroundStyle(p.foreground.color)
                        .textSelection(.enabled)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(p.sidebar.color.opacity(0.15))
    }
    
    private func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(store.notesContent, forType: .string)
    }
    
    private func clearNotes() {
        let alert = NSAlert()
        alert.messageText = "Clear Scratchpad?"
        alert.informativeText = "This action cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Clear")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            store.notesContent = ""
        }
    }
}
