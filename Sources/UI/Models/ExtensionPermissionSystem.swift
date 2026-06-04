import Foundation

/// Dynamic Permission Opt-In System (Roadmap Item 76)
/// Requires user confirmation when an extension attempts to access new domains
/// or storage APIs.
struct ExtensionPermissionRequest: Identifiable {
    let id = UUID()
    let extensionID: String
    let extensionName: String
    let permission: String
    let domain: String?
    let timestamp = Date()
}

final class ExtensionPermissionSystem: ObservableObject {
    static let shared = ExtensionPermissionSystem()

    @Published var pendingRequests: [ExtensionPermissionRequest] = []
    @Published var grantedPermissions: [String: Set<String>] = [:]

    private init() {}

    func requestPermission(extensionID: String, extensionName: String, permission: String, domain: String?, completion: @escaping (Bool) -> Void) {
        let key = "\(extensionID):\(permission):\(domain ?? "*")"
        if let granted = grantedPermissions[extensionID], granted.contains(key) {
            completion(true)
            return
        }

        let request = ExtensionPermissionRequest(
            extensionID: extensionID,
            extensionName: extensionName,
            permission: permission,
            domain: domain
        )
        pendingRequests.append(request)

        // In production: show native permission modal.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.pendingRequests.removeAll { $0.id == request.id }
            self?.grantedPermissions[extensionID, default: []].insert(key)
            completion(true)
        }
    }

    func revoke(extensionID: String, permission: String) {
        grantedPermissions[extensionID]?.remove(permission)
    }
}
