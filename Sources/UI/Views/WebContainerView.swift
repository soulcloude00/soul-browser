import SwiftUI
import AppKit

/// Hosts the live CEF browser views. All realized tabs stay mounted (so they
/// keep running like real background tabs); only the selected one is visible.
struct WebContainerView: NSViewRepresentable {
    @ObservedObject var store: BrowserStore
    @ObservedObject var activeTab: BrowserTab
    /// Corner radius applied to the container's layer so the live CEF content is
    /// clipped to the rounded "card" — SwiftUI `.clipShape` can't clip a hosted
    /// AppKit view, so the rounding has to happen on the layer itself.
    var cornerRadius: CGFloat = 0

    func makeNSView(context: Context) -> ContainerView {
        let view = ContainerView()
        view.applyCornerRadius(cornerRadius)
        return view
    }

    func updateNSView(_ nsView: ContainerView, context: Context) {
        nsView.applyCornerRadius(cornerRadius)

        // Settings is a window-modal sheet, so hide Chromium while it is up.
        SoulBrowserView.setWebContentSuppressed(store.settingsVisible)

        // Make sure the selected tab is realized.
        store.selectedTab?.realize()

        let realizedTabs = store.tabs.filter { $0.hasRealized }
        let liveViews = realizedTabs.map { $0.browserView }

        // Find if active tab is split with another realized tab
        let splitTab = activeTab.splitTabID.flatMap { sid in store.tabs.first(where: { $0.id == sid && $0.hasRealized }) }
        let hasSplit = splitTab != nil && !(splitTab?.isSuspended ?? true)

        // Remove views whose tabs are gone, ignoring the splitView itself.
        for sub in nsView.subviews where sub !== nsView.splitView && !(liveViews.contains { $0 === sub }) {
            sub.removeFromSuperview()
        }

        if hasSplit, let splitTab = splitTab {
            if nsView.splitView.superview !== nsView {
                nsView.addSubview(nsView.splitView)
            }
            nsView.splitView.isHidden = false
            nsView.splitView.frame = nsView.bounds
            nsView.splitView.autoresizingMask = [.width, .height]

            let activeView = activeTab.browserView
            let otherView = splitTab.browserView

            // Order subviews in split view
            if nsView.splitView.subviews.count != 2 || nsView.splitView.subviews[0] !== activeView || nsView.splitView.subviews[1] !== otherView {
                nsView.splitView.subviews.forEach { $0.removeFromSuperview() }
                activeView.removeFromSuperview()
                otherView.removeFromSuperview()
                nsView.splitView.addSubview(activeView)
                nsView.splitView.addSubview(otherView)
            }

            activeView.isHidden = activeTab.didFail
            activeView.setWebWindowVisible(!activeTab.didFail)
            activeView.setPageHidden(activeTab.didFail)

            otherView.isHidden = splitTab.didFail
            otherView.setWebWindowVisible(!splitTab.didFail)
            otherView.setPageHidden(splitTab.didFail)

            nsView.splitView.adjustSubviews()
        } else {
            nsView.splitView.isHidden = true
            if nsView.splitView.superview != nil {
                nsView.splitView.removeFromSuperview()
            }
            nsView.splitView.subviews.forEach { $0.removeFromSuperview() }
        }

        // Add, position, and set visibility for other/hidden realized tabs.
        for tab in realizedTabs {
            let view = tab.browserView
            
            if hasSplit && (tab.id == activeTab.id || tab.id == activeTab.splitTabID) {
                continue // Positioned in split view
            }

            if view.superview !== nsView {
                view.removeFromSuperview()
                nsView.addSubview(view)
            }
            view.frame = nsView.bounds
            view.autoresizingMask = [.width, .height]
            let hidden = (tab.id != store.selectedTabID) || tab.didFail
            view.isHidden = hidden
            view.setWebWindowVisible(!hidden)
            view.setPageHidden(hidden)
        }

        // Keep the active browser keyboard-focused.
        if !activeTab.didFail {
            activeTab.browserView.isHidden = false
            activeTab.browserView.setWebWindowVisible(true)
        }
    }

    /// Flipped container so child frames use top-left origin.
    final class ContainerView: NSView {
        override var isFlipped: Bool { true }

        let splitView: NSSplitView = {
            let sv = NSSplitView()
            sv.isVertical = true
            sv.dividerStyle = .thin
            return sv
        }()

        /// Round (and clip to) the layer so the hosted CEF subviews are masked
        /// to the card shape. `.continuous` matches SwiftUI's squircle corners.
        func applyCornerRadius(_ radius: CGFloat) {
            wantsLayer = true
            guard let layer else { return }
            if layer.cornerRadius != radius { layer.cornerRadius = radius }
            layer.cornerCurve = .continuous
            layer.masksToBounds = radius > 0
        }

        override func layout() {
            super.layout()
            for sub in subviews {
                if sub === splitView {
                    sub.frame = bounds
                } else if sub.isHidden {
                    sub.frame = bounds
                }
            }
        }
        override func setFrameSize(_ newSize: NSSize) {
            super.setFrameSize(newSize)
            for sub in subviews {
                if sub === splitView {
                    sub.frame = bounds
                } else if sub.isHidden {
                    sub.frame = bounds
                }
            }
        }
    }
}

/// Wraps a single SoulBrowserView in an NSViewRepresentable so it can be laid out
/// alongside other views in SwiftUI (for example, in Matrix Mode).
struct SingleWebView: NSViewRepresentable {
    let browserView: SoulBrowserView

    func makeNSView(context: Context) -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.black.cgColor
        container.addSubview(browserView)
        return container
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if browserView.superview !== nsView {
            browserView.removeFromSuperview()
            nsView.addSubview(browserView)
        }
        browserView.frame = nsView.bounds
        browserView.autoresizingMask = [.width, .height]
        
        // Ensure visibility is correct when moved
        browserView.isHidden = false
        browserView.setWebWindowVisible(true)
        browserView.setPageHidden(false)
    }
}
