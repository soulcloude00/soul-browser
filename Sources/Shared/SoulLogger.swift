import Foundation
import os.log

/// Unified logging utility for Soul browser using os.log framework.
/// Provides structured logging with different log levels and categories.
enum SoulLogger {
    
    // MARK: - Log Categories
    
    /// General application lifecycle events
    static let app = OSLog(subsystem: "com.soul.browser", category: "App")
    
    /// Browser navigation and tab management
    static let browser = OSLog(subsystem: "com.soul.browser", category: "Browser")
    
    /// Extension system events
    static let extensions = OSLog(subsystem: "com.soul.browser", category: "Extensions")
    
    /// Database operations (history, bookmarks, etc.)
    static let database = OSLog(subsystem: "com.soul.browser", category: "Database")
    
    /// Network operations
    static let network = OSLog(subsystem: "com.soul.browser", category: "Network")
    
    /// CEF/Chromium engine events
    static let engine = OSLog(subsystem: "com.soul.browser", category: "Engine")
    
    /// Security and privacy events
    static let security = OSLog(subsystem: "com.soul.browser", category: "Security")
    
    /// AI/Codex integration
    static let ai = OSLog(subsystem: "com.soul.browser", category: "AI")
    
    // MARK: - Log Methods
    
    /// Log a debug message
    static func debug(_ message: String, category: OSLog = app, _ args: CVarArg...) {
        os_log("%{public}@", log: category, type: .debug, message)
    }
    
    /// Log an info message
    static func info(_ message: String, category: OSLog = app, _ args: CVarArg...) {
        os_log("%{public}@", log: category, type: .info, message)
    }
    
    /// Log a default (info) message
    static func log(_ message: String, category: OSLog = app, _ args: CVarArg...) {
        os_log("%{public}@", log: category, type: .default, message)
    }
    
    /// Log an error message
    static func error(_ message: String, category: OSLog = app, _ args: CVarArg...) {
        os_log("%{public}@", log: category, type: .error, message)
    }
    
    /// Log a fault (critical error) message
    static func fault(_ message: String, category: OSLog = app, _ args: CVarArg...) {
        os_log("%{public}@", log: category, type: .fault, message)
    }
    
    // MARK: - Convenience Methods with Error Context
    
    /// Log an error with associated Error object
    static func error(_ message: String, error: Error?, category: OSLog = app) {
        if let error = error {
            os_log("%{public}@: %{public}@", log: category, type: .error, message, String(describing: error))
        } else {
            os_log("%{public}@", log: category, type: .error, message)
        }
    }
    
    /// Log a fault with associated Error object
    static func fault(_ message: String, error: Error?, category: OSLog = app) {
        if let error = error {
            os_log("%{public}@: %{public}@", log: category, type: .fault, message, String(describing: error))
        } else {
            os_log("%{public}@", log: category, type: .fault, message)
        }
    }
}
