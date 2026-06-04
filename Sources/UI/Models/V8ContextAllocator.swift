import Foundation

/// Shared V8 Engine Context Allocator (Roadmap Item 27)
/// Optimizes the CEF command line arguments to share renderer structures
/// and isolate V8 contexts more efficiently across same-origin pages.
final class V8ContextAllocator {
    static let shared = V8ContextAllocator()

    private init() {}

    var optimizedArgs: [String] {
        [
            "--process-per-site",
            "--site-per-process",
            "--enable-features=V8VmFuture,V8PerContextSnapshot",
            "--disable-features=V8LazyParsing",
            "--max-old-space-size=4096",
            "--v8-cache-options=code",
            "--v8-cache-strategy-for-modules=advanced"
        ]
    }

    func commandLineArgs() -> [String] {
        SoulLogger.log("V8ContextAllocator: applied shared context optimization")
        return optimizedArgs
    }
}
