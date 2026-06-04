import SwiftUI

/// Developer panel for viewing and editing cookies, localStorage, and
/// sessionStorage for the current tab.
struct CookieEditorPanel: View {
    @ObservedObject var store: BrowserStore
    @ObservedObject private var editor = CookieLocalStorageEditor.shared
    @Environment(\.palette) private var p
    @State private var filterText = ""
    @State private var editingItem: StorageItem?
    @State private var editValue = ""

    private var filteredItems: [StorageItem] {
        if filterText.isEmpty { return editor.items }
        return editor.items.filter {
            $0.key.localizedCaseInsensitiveContains(filterText) ||
            $0.value.localizedCaseInsensitiveContains(filterText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cookie & Storage Editor")
                    .font(Typography.ui(16, weight: .semibold))
                    .foregroundStyle(p.foreground.color)
                Spacer()
                Button {
                    if let tab = store.selectedTab {
                        editor.scan(tab: tab)
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(p.accent.color)
                }
                .buttonStyle(.plain)
                .help("Refresh")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            TextField("Filter...", text: $filterText)
                .textFieldStyle(.plain)
                .padding(8)
                .background(p.input.color.opacity(0.5))
                .cornerRadius(Radius.md)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            if filteredItems.isEmpty {
                Spacer()
                Text("No storage items found")
                    .font(Typography.ui(Typography.base))
                    .foregroundStyle(p.mutedForeground.color)
                Spacer()
            } else {
                List {
                    ForEach(filteredItems) { item in
                        StorageItemRow(item: item, p: p,
                                       onEdit: { beginEdit(item) },
                                       onDelete: { deleteItem(item) })
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .frame(width: 380)
        .background(p.background.color)
        .onAppear {
            if let tab = store.selectedTab {
                editor.scan(tab: tab)
            }
        }
        .sheet(item: $editingItem) { item in
            EditStorageItemSheet(item: item, p: p,
                                 onSave: { newValue in
                if let tab = store.selectedTab {
                    editor.update(item: item, newValue: newValue, in: tab)
                    editor.scan(tab: tab)
                }
                editingItem = nil
            }, onCancel: {
                editingItem = nil
            })
        }
    }

    private func beginEdit(_ item: StorageItem) {
        editingItem = item
        editValue = item.value
    }

    private func deleteItem(_ item: StorageItem) {
        if let tab = store.selectedTab {
            editor.delete(item: item, in: tab)
            editor.scan(tab: tab)
        }
    }
}

private struct StorageItemRow: View {
    let item: StorageItem
    let p: ThemePalette
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.key)
                    .font(Typography.ui(13, weight: .medium))
                    .foregroundStyle(p.foreground.color)
                    .lineLimit(1)
                Text(item.value)
                    .font(Typography.ui(Typography.small))
                    .foregroundStyle(p.mutedForeground.color)
                    .lineLimit(1)
                Text(item.type.rawValue)
                    .font(Typography.ui(10, weight: .medium))
                    .foregroundStyle(p.accent.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(p.accent.color.opacity(0.15))
                    .cornerRadius(Radius.sm)
            }
            Spacer()
            HStack(spacing: 4) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 11))
                        .foregroundStyle(p.mutedForeground.color)
                }
                .buttonStyle(.plain)
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundStyle(p.statusWarningFg.color)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(p.card.color.opacity(0.3))
        .cornerRadius(Radius.md)
        .padding(.horizontal, 12)
    }
}

private struct EditStorageItemSheet: View {
    let item: StorageItem
    let p: ThemePalette
    let onSave: (String) -> Void
    let onCancel: () -> Void
    @State private var value: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Edit \(item.type.rawValue)")
                .font(Typography.ui(16, weight: .semibold))
                .foregroundStyle(p.foreground.color)

            Text(item.key)
                .font(Typography.ui(13, weight: .medium))
                .foregroundStyle(p.mutedForeground.color)

            TextEditor(text: $value)
                .font(Typography.ui(Typography.base))
                .frame(height: 100)
                .padding(8)
                .background(p.input.color.opacity(0.5))
                .cornerRadius(Radius.md)

            HStack(spacing: 12) {
                Button("Cancel", action: onCancel)
                    .buttonStyle(.borderless)
                Button("Save") {
                    onSave(value)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 400)
        .background(p.background.color)
        .onAppear { value = item.value }
    }
}


