import Foundation
import os.log

/// Utility for cleaning up old workspace cache directories that are no longer in use.
enum WorkspaceCacheCleanup {
    
    /// Remove workspace cache directories that are not in the active workspaces list.
    /// This should be called on app startup to prevent accumulation of unused cache data.
    static func cleanupUnusedWorkspaces(activeWorkspaceIDs: Set<String>) {
        let fm = FileManager.default
        guard let supportDir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            SoulLogger.error("Failed to get Application Support directory for workspace cleanup", category: SoulLogger.database)
            return
        }
        
        let workspacesDir = supportDir.appendingPathComponent("SoulBrowser/Workspaces", isDirectory: true)
        
        // Check if the workspaces directory exists
        guard fm.fileExists(atPath: workspacesDir.path) else {
            return
        }
        
        do {
            let workspaceDirs = try fm.contentsOfDirectory(at: workspacesDir, includingPropertiesForKeys: nil)
            
            for workspaceDir in workspaceDirs {
                let workspaceID = workspaceDir.lastPathComponent
                
                // Skip the "personal" workspace (uses global context, not a separate cache)
                if workspaceID == "personal" {
                    continue
                }
                
                // Skip if this workspace is still active
                if activeWorkspaceIDs.contains(workspaceID) {
                    continue
                }
                
                // Remove the unused workspace cache directory
                try fm.removeItem(at: workspaceDir)
                SoulLogger.info("Cleaned up unused workspace cache: \(workspaceID)", category: SoulLogger.database)
            }
        } catch {
            SoulLogger.error("Failed to cleanup workspace caches: \(error.localizedDescription)", category: SoulLogger.database)
        }
    }
}
