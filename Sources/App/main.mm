// Soul Browser — browser-process entry point.
//
// Responsibilities:
//   1. Dynamically load the embedded CEF framework.
//   2. Stand up the CEF context with our CefApp.
//   3. Create the AppKit application + window hosting the SwiftUI chrome.
//   4. Run the CEF message loop (which drives AppKit) until quit.

#import <Cocoa/Cocoa.h>

#include "include/cef_app.h"
#include "include/wrapper/cef_library_loader.h"

#import "AppDelegate.h"
#import "CefAppImpl.h"
#import "SoulApplication.h"

namespace {

// Resolve a writable cache directory so history/cookies/localStorage persist
// across launches, matching real-browser behavior.
std::string DefaultCachePath() {
  NSArray<NSString*>* dirs = NSSearchPathForDirectoriesInDomains(
      NSApplicationSupportDirectory, NSUserDomainMask, YES);
  NSString* base = dirs.firstObject ?: NSTemporaryDirectory();
  NSString* path = [base stringByAppendingPathComponent:@"SoulBrowser/Default"];
  [[NSFileManager defaultManager] createDirectoryAtPath:path
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:nil];
  return std::string([path UTF8String]);
}

// The embedded CEF framework directory inside the app bundle.
std::string FrameworkDirPath() {
  NSString* fw = [[[NSBundle mainBundle] privateFrameworksPath]
      stringByAppendingPathComponent:@"Chromium Embedded Framework.framework"];
  return std::string([fw UTF8String]);
}

}  // namespace

int main(int argc, char* argv[]) {
  @autoreleasepool {
    // 1. Load the CEF framework for the main (browser) process.
    CefScopedLibraryLoader library_loader;
    if (!library_loader.LoadInMain()) {
      NSLog(@"Soul: failed to load the CEF framework.");
      return 1;
    }

    CefMainArgs main_args(argc, argv);

    // 2. Instantiate the custom NSApplication required by CEF.
    [SoulApplication sharedApplication];

    CefRefPtr<CefAppImpl> app(new CefAppImpl);

    CefSettings settings;
    settings.no_sandbox = true;  // No cef_sandbox.a in the minimal distribution.
    settings.windowless_rendering_enabled = false;
    settings.log_severity = LOGSEVERITY_WARNING;
    // Persist *session* cookies too (not just long-lived ones), so logins and
    // "remember me" sessions survive a relaunch the way every modern browser
    // does. Persistent cookies/localStorage already persist via cache_path.
    settings.persist_session_cookies = true;

    CefString(&settings.framework_dir_path) = FrameworkDirPath();
    CefString(&settings.cache_path) = DefaultCachePath();
    CefString(&settings.root_cache_path) = DefaultCachePath();

    // 3. Initialize the global CEF context.
    if (!CefInitialize(main_args, settings, app.get(), nullptr)) {
      NSLog(@"Soul: CefInitialize failed (exit code %d).",
            CefGetExitCode());
      return CefGetExitCode();
    }

    // 4. Wire up the AppKit delegate that builds the SwiftUI window.
    AppDelegate* delegate = [[AppDelegate alloc] init];
    NSApp.delegate = delegate;

    // 5. Cooperative CEF message-loop pump.
    //    CefDoMessageLoopWork() is called at 30 Hz on the main run loop.
    //    A slower cadence (33 ms) leaves AppKit far more time to process
    //    UI events, eliminating the "missed clicks" symptom that appeared
    //    when the pump was running at 120 Hz (and even 60 Hz).
    NSTimer* cefPump = [NSTimer timerWithTimeInterval:(1.0 / 30.0)
                                                repeats:YES
                                                  block:^(NSTimer* _Nonnull timer) {
                                                      CefDoMessageLoopWork();
                                                  }];
    [[NSRunLoop mainRunLoop] addTimer:cefPump forMode:NSRunLoopCommonModes];

    // 6. Run the native AppKit event loop (now driving CEF cooperatively).
    [NSApp run];

    // 7. Tear down.
    [cefPump invalidate];
    CefShutdown();
  }
  return 0;
}
