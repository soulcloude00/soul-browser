import Foundation

/// Granular Permission Controls (Roadmap Item 66)
/// Build a prompt system asking for camera, microphone, geolocation, and
/// clipboard access per domain.
struct PermissionRequest: Identifiable {
    let id = UUID()
    let domain: String
    let type: PermissionType
    let date = Date()

    enum PermissionType: String, CaseIterable {
        case camera = "Camera"
        case microphone = "Microphone"
        case geolocation = "Location"
        case clipboard = "Clipboard"
        case notifications = "Notifications"
    }
}

final class PermissionControls: ObservableObject {
    static let shared = PermissionControls()

    @Published var pendingRequests: [PermissionRequest] = []
    @Published var grantedPermissions: [String: Set<PermissionRequest.PermissionType>] = [:]

    private init() {}

    func requestPermission(domain: String, type: PermissionRequest.PermissionType, completion: @escaping (Bool) -> Void) {
        let key = "\(domain):\(type.rawValue)"
        if let granted = grantedPermissions[domain], granted.contains(type) {
            completion(true)
            return
        }

        let request = PermissionRequest(domain: domain, type: type)
        pendingRequests.append(request)

        // In a real implementation this would show a native modal.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.pendingRequests.removeAll { $0.id == request.id }
            self?.grantedPermissions[domain, default: []].insert(type)
            completion(true)
        }
    }

    func revokePermission(domain: String, type: PermissionRequest.PermissionType) {
        grantedPermissions[domain]?.remove(type)
    }

    func revokeAll(for domain: String) {
        grantedPermissions.removeValue(forKey: domain)
    }
}
