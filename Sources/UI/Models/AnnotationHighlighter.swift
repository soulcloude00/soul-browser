import Foundation

/// In-Page Interactive Annotation Highlight Tool (Roadmap Item 104)
/// Injects custom persistent stylesheets and layers over target pages, allowing
/// users to draw and highlight text. Saves annotations to the local Soul database.
struct Annotation: Identifiable, Codable {
    let id = UUID()
    let url: String
    let selector: String
    let text: String
    let color: String
    let note: String
    let createdAt: Date
}

final class AnnotationHighlighter: ObservableObject {
    static let shared = AnnotationHighlighter()

    @Published var annotations: [Annotation] = []

    private init() {
        loadAnnotations()
    }

    func highlightSelection(in tab: BrowserTab, color: String, note: String = "") {
        let js = """
        (function() {
            const sel = window.getSelection();
            if (!sel.rangeCount) return null;
            const range = sel.getRangeAt(0);
            const span = document.createElement('span');
            span.style.backgroundColor = '\(color)';
            span.style.cursor = 'pointer';
            span.dataset.soulAnnotation = 'true';
            try {
                range.surroundContents(span);
                return {selector: '', text: span.textContent};
            } catch(e) {
                return null;
            }
        })();
        """
        tab.browserView.evaluateJavaScript(js) { [weak self] result, _ in
            guard let dict = result as? [String: String],
                  let text = dict["text"] else { return }
            let annotation = Annotation(
                url: tab.urlString,
                selector: dict["selector"] ?? "",
                text: text,
                color: color,
                note: note,
                createdAt: Date()
            )
            self?.annotations.append(annotation)
            self?.saveAnnotations()
        }
    }

    private func saveAnnotations() {
        let fm = FileManager.default
        let url = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("SoulBrowser/annotations.json")
        guard let url, let data = try? JSONEncoder().encode(annotations) else { return }
        try? data.write(to: url, options: .atomic)
    }

    private func loadAnnotations() {
        let fm = FileManager.default
        let url = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("SoulBrowser/annotations.json")
        guard let url, let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Annotation].self, from: data) else { return }
        annotations = decoded
    }
}
