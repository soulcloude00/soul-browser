// Swift-facing wrapper around a single CEF browser, presented as an NSView.
//
// This header is intentionally free of any CEF/C++ types so it can be imported
// from Swift through the bridging header. All Chromium interaction lives in the
// .mm implementation.
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class SoulBrowserView;

typedef void (^SoulJavaScriptResultHandler)(id _Nullable result,
                                              NSString *_Nullable errorMessage);

/// Navigation/display state callbacks. All methods are delivered on the main
/// thread, so delegates may update UI directly.
@protocol SoulBrowserViewDelegate <NSObject>
@optional
- (void)browserView:(SoulBrowserView *)view didChangeTitle:(NSString *)title;
- (void)browserView:(SoulBrowserView *)view didChangeURL:(NSString *)url;
- (void)browserView:(SoulBrowserView *)view
    didChangeLoading:(BOOL)isLoading
           canGoBack:(BOOL)canGoBack
        canGoForward:(BOOL)canGoForward;
- (void)browserView:(SoulBrowserView *)view
    didChangeFaviconURLs:(NSArray<NSString *> *)urls;
- (void)browserView:(SoulBrowserView *)view
    didStartNavigationToURL:(NSString *)url
                 isRedirect:(BOOL)isRedirect
                userGesture:(BOOL)userGesture;
- (void)browserView:(SoulBrowserView *)view
    didCommitNavigationToURL:(NSString *)url;
- (void)browserView:(SoulBrowserView *)view
    didFinishNavigationToURL:(NSString *)url
              httpStatusCode:(NSInteger)httpStatusCode;
- (void)browserView:(SoulBrowserView *)view
       didFailLoad:(NSString *)errorText
         failedURL:(NSString *)failedURL;
/// A popup / target=_blank navigation that should open in a brand new tab.
- (void)browserView:(SoulBrowserView *)view
    requestsNewTabWithURL:(NSString *)url;
/// Find-in-page match results: 1-based index of the active match and the total
/// number of matches for the current query (0 when there are none).
- (void)browserView:(SoulBrowserView *)view
    didUpdateFindMatchOrdinal:(int)ordinal
                     ofMatches:(int)count;
- (void)browserView:(SoulBrowserView *)view
    didBlockTracker:(NSString *)host;
@end

@interface SoulBrowserView : NSView

@property(nonatomic, weak, nullable) id<SoulBrowserViewDelegate> navDelegate;
@property(nonatomic) NSInteger extensionTabID;

/// Live state, kept in sync for convenience (also pushed via the delegate).
@property(nonatomic, copy, readonly) NSString *currentURL;
@property(nonatomic, copy, readonly) NSString *currentTitle;
@property(nonatomic, readonly) BOOL isLoading;
@property(nonatomic, readonly) BOOL canGoBack;
@property(nonatomic, readonly) BOOL canGoForward;

/// Create a new browser view starting at the given URL in the given workspace.
- (instancetype)initWithURL:(NSString*)url workspaceID:(NSString*)workspaceID;

/// Create a new browser view starting at the given URL in the personal workspace.
- (instancetype)initWithURL:(NSString*)url;

- (void)loadURL:(NSString *)url;
- (void)goBack;
- (void)goForward;
- (void)reload;
- (void)reloadIgnoringCache;
- (void)stopLoading;

/// Page zoom. Steps are relative to the browser's current zoom; reset returns
/// to 100%.
- (void)zoomIn;
- (void)zoomOut;
- (void)resetZoom;
- (void)setZoomFactor:(double)factor;

/// Find-in-page. `findText:` highlights matches and scrolls to the next/prev
/// one; results arrive via the delegate. `stopFinding:` clears the highlights.
- (void)findText:(NSString *)text forward:(BOOL)forward;
- (void)stopFinding:(BOOL)clearSelection;

/// Developer tools for the underlying browser.
- (void)showDevTools;
- (void)closeDevTools;
- (void)toggleDevTools;

/// Open the system print dialog for the current page.
- (void)printPage;

/// Start a Chromium-owned download without navigating the tab.
- (BOOL)startDownload:(NSString *)url
          extensionID:(NSString *)extensionID
            requestID:(NSString *)requestID
             filename:(nullable NSString *)filename;

/// Run extension-owned JavaScript in the current page. Used by Soul's
/// `chrome.scripting` bridge; it does not expose CEF types to Swift.
- (void)executeExtensionJavaScript:(NSString *)source allFrames:(BOOL)allFrames;

/// Evaluate JavaScript in the main frame and return a JSON-serializable result
/// via Chromium's DevTools protocol. Used by Soul's local AI tools.
- (BOOL)evaluateJavaScript:(NSString *)source
                completion:(SoulJavaScriptResultHandler)completion;

/// Capture the current page through Chromium's DevTools protocol and resolve
/// the extension bridge request asynchronously with a PNG data URL.
- (BOOL)captureVisiblePNGDataURLForExtensionID:(NSString *)extensionID
                                     requestID:(NSString *)requestID;

/// Make this browser the first responder / give it keyboard focus.
- (void)focusBrowser;

/// CEF browser identifier (0 until the browser exists). Used to attribute
/// media-player updates broadcast from the engine to this tab.
@property(nonatomic, readonly) int browserIdentifier;

/// Drive the injected media agent (play/pause/seek/skip/mute/pip).
- (void)sendMediaCommand:(NSString *)action value:(double)value;

/// Tell Chromium this page is (un)occluded — flips `document.hidden`, which
/// drives throttling and the auto-PiP-on-tab-switch behavior.
- (void)setPageHidden:(BOOL)hidden;

/// Explicitly show/hide the native Chromium child view for this tab. This is
/// separate from NSView.hidden because CEF keeps its own visibility state.
- (void)setWebWindowVisible:(BOOL)visible;

/// Let chrome-owned auxiliary views (extension action popovers, etc.) remain
/// drawable while Soul hides normal tab web content behind full-window UI.
- (void)setIgnoresGlobalWebContentSuppression:(BOOL)ignores;

/// Push the auto-PiP preference into this (already-loaded) page.
- (void)applyAutoPiP:(BOOL)enabled;

/// Cap the CEF renderer's maximum frame rate to reduce CPU/GPU usage (Low Power Mode).
/// Setting to 0 restores the default (usually 60fps).
- (void)setFrameRateLimit:(int)fps;

/// Set the process-wide auto-PiP default applied to newly loaded pages.
+ (void)setAutoPiPEnabled:(BOOL)enabled;
+ (void)setAdBlockerEnabled:(BOOL)enabled;
+ (void)setAdBlockExceptions:(NSArray<NSString *> *)exceptions;
+ (void)setHTTPSOnlyEnabled:(BOOL)enabled;

/// Cancel an active Chromium-owned download by id.
+ (BOOL)cancelDownloadWithID:(uint32_t)downloadID;

/// Hide every live web view at once while a full-window SwiftUI overlay (e.g.
/// the new-tab launcher or Settings) is presented.
+ (void)setWebContentSuppressed:(BOOL)suppressed;

/// Deliver an extension runtime message to every live Chromium context Soul
/// owns: visible tabs, popovers, and hidden background runners.
+ (void)dispatchExtensionMessage:(id)message
                  forExtensionID:(NSString *)extensionID;
+ (void)dispatchExtensionMessage:(id)message
                  forExtensionID:(NSString *)extensionID
                       requestID:(nullable NSString *)requestID;
+ (void)dispatchExtensionMessage:(id)message
                  forExtensionID:(NSString *)extensionID
                       requestID:(nullable NSString *)requestID
                       sourceURL:(nullable NSString *)sourceURL;
+ (void)dispatchExtensionMessage:(id)message
                  forExtensionID:(NSString *)extensionID
                       requestID:(nullable NSString *)requestID
                       sourceURL:(nullable NSString *)sourceURL
                    sourceOrigin:(nullable NSString *)sourceOrigin;

/// Resolve an extension bridge request in every live Chromium context. The
/// frame with the matching pending request id consumes it; every other frame
/// ignores it.
+ (void)dispatchExtensionBridgeResponse:(NSDictionary *)response;

/// Fire a Chrome-style extension event (`tabs.onUpdated`, etc.) in every live
/// extension context. `extensionID == nil` broadcasts to all extensions.
+ (void)dispatchExtensionEvent:(NSString *)eventName
                          args:(NSArray *)args
                forExtensionID:(nullable NSString *)extensionID;

/// Run a custom extension-runtime dispatch snippet in live Chromium contexts.
/// The snippet is guarded to the requested extension when `extensionID` is set.
+ (void)broadcastExtensionJavaScript:(NSString *)source
                      forExtensionID:(nullable NSString *)extensionID;

/// Close the underlying CEF browser. Safe to call multiple times.
- (void)closeBrowser;

@end

NS_ASSUME_NONNULL_END
