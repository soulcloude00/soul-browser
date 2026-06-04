import Foundation

/// Intelligent Audio/Video Stream Downloader (Roadmap Item 101)
/// Intercepts multimedia stream sources (HLS/m3u8, MP4, MP3) and routes them
/// to DownloadStore.swift with format options.
struct StreamFormat: Identifiable {
    let id = UUID()
    let quality: String
    let url: String
    let size: String?
    let mimeType: String
}

final class StreamDownloader: ObservableObject {
    static let shared = StreamDownloader()

    @Published var detectedFormats: [StreamFormat] = []
    @Published var isAnalyzing = false

    private init() {}

    func analyzePage(in tab: BrowserTab) {
        isAnalyzing = true
        let js = """
        (function() {
            const sources = [];
            document.querySelectorAll('video source, audio source').forEach(el => {
                sources.push({url: el.src, type: el.type || 'unknown'});
            });
            // Look for HLS manifests in network-adjacent script variables
            const html = document.documentElement.innerHTML;
            const m3u8Match = html.match(/(https?:\\/\\/[^\\s\"]+\\.m3u8)/);
            if (m3u8Match) sources.push({url: m3u8Match[1], type: 'application/x-mpegURL'});
            return sources;
        })();
        """
        tab.browserView.evaluateJavaScript(js) { [weak self] result, _ in
            self?.isAnalyzing = false
            guard let array = result as? [[String: String]] else { return }
            self?.detectedFormats = array.map { dict in
                StreamFormat(
                    quality: "Auto",
                    url: dict["url"] ?? "",
                    size: nil,
                    mimeType: dict["type"] ?? "video/mp4"
                )
            }
        }
    }

    func download(format: StreamFormat) {
        guard let url = URL(string: format.url) else { return }
        let task = URLSession.shared.downloadTask(with: url) { localURL, _, _ in
            guard let localURL else { return }
            let ext = format.mimeType.contains("audio") ? "mp3" : "mp4"
            let dest = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?
                .appendingPathComponent("soul_download_\(Int.random(in: 1000...9999)).\(ext)")
            guard let dest else { return }
            try? FileManager.default.moveItem(at: localURL, to: dest)
        }
        task.resume()
    }
}
