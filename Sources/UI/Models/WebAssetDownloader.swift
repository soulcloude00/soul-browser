import Foundation

/// Web Asset Downloader (Roadmap Item 57)
/// Compiles a media resources panel that lists all images, videos, fonts, and
/// stylesheets loaded on the current tab.
struct WebAsset: Identifiable {
    let id = UUID()
    let url: String
    let type: AssetType
    let size: Int?
    let mimeType: String?

    enum AssetType: String, CaseIterable {
        case image = "Image"
        case video = "Video"
        case audio = "Audio"
        case font = "Font"
        case stylesheet = "Stylesheet"
        case script = "Script"
        case other = "Other"
    }
}

final class WebAssetDownloader: ObservableObject {
    static let shared = WebAssetDownloader()

    @Published var assets: [WebAsset] = []

    private init() {}

    func scan(tab: BrowserTab) {
        let js = """
        (function() {
            const results = [];
            const add = (url, type, mime) => { if (url) results.push({url, type, mime, size: 0}); };
            document.querySelectorAll('img').forEach(el => add(el.src, 'Image', null));
            document.querySelectorAll('video source').forEach(el => add(el.src, 'Video', el.type));
            document.querySelectorAll('audio source').forEach(el => add(el.src, 'Audio', el.type));
            document.querySelectorAll('link[rel="stylesheet"]').forEach(el => add(el.href, 'Stylesheet', 'text/css'));
            document.querySelectorAll('script[src]').forEach(el => add(el.src, 'Script', 'text/javascript'));
            document.fonts.forEach(font => add(new URL(font.family, location.href).href, 'Font', null));
            return results;
        })();
        """
        tab.browserView.evaluateJavaScript(js) { [weak self] result, _ in
            guard let array = result as? [[String: Any]] else { return }
            self?.assets = array.compactMap { dict in
                guard let url = dict["url"] as? String else { return nil }
                let typeStr = dict["type"] as? String ?? "Other"
                let type = WebAsset.AssetType(rawValue: typeStr) ?? .other
                return WebAsset(url: url, type: type, size: dict["size"] as? Int, mimeType: dict["mime"] as? String)
            }
        }
    }

    func download(asset: WebAsset) {
        guard let url = URL(string: asset.url) else { return }
        let task = URLSession.shared.downloadTask(with: url) { localURL, _, _ in
            guard let localURL else { return }
            let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
            let dest = downloads?.appendingPathComponent(url.lastPathComponent) ?? localURL
            try? FileManager.default.moveItem(at: localURL, to: dest)
        }
        task.resume()
    }
}
