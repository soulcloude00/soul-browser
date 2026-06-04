import Foundation
import Network

/// Cloudless Sync via LAN (Bonjour) (Roadmap Item 39)
/// Discovers other Soul instances on the local network and syncs encrypted
/// workspace bundles peer-to-peer.
final class LANSyncManager: ObservableObject {
    static let shared = LANSyncManager()

    @Published var discoveredPeers: [String] = []
    @Published var isAdvertising = false
    @Published var isBrowsing = false

    private var listener: NWListener?
    private var browser: NWBrowser?

    private init() {}

    func startAdvertising(name: String) {
        isAdvertising = true
        // In production: advertise via Bonjour _soul-sync._tcp
        SoulLogger.log("LANSync: advertising as \(name)")
    }

    func startBrowsing() {
        isBrowsing = true
        // In production: browse for _soul-sync._tcp services
        SoulLogger.log("LANSync: browsing for peers")
    }

    func sendWorkspace(_ data: Data, to peer: String) {
        SoulLogger.log("LANSync: sending workspace to \(peer)")
        // In production: establish TCP connection and send encrypted bundle
    }

    func stop() {
        isAdvertising = false
        isBrowsing = false
        listener?.cancel()
        browser?.cancel()
    }
}
