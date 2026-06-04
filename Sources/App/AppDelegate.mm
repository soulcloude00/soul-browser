#import "AppDelegate.h"

#include "include/cef_app.h"
#include "include/wrapper/cef_helpers.h"

// Generated from the Swift @objc interface (SWIFT_OBJC_INTERFACE_HEADER_NAME).
#import "Soul-Swift.h"

@interface AppDelegate ()
@property(nonatomic, strong) NSWindow* mainWindow;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
  [self buildMainMenu];

  NSRect frame = NSMakeRect(0, 0, 1280, 820);
  NSWindowStyleMask style = NSWindowStyleMaskTitled |
                            NSWindowStyleMaskClosable |
                            NSWindowStyleMaskMiniaturizable |
                            NSWindowStyleMaskResizable |
                            NSWindowStyleMaskFullSizeContentView;

  self.mainWindow = [[NSWindow alloc] initWithContentRect:frame
                                                styleMask:style
                                                  backing:NSBackingStoreBuffered
                                                    defer:NO];
  self.mainWindow.title = @"Soul";
  self.mainWindow.titlebarAppearsTransparent = YES;
  self.mainWindow.titleVisibility = NSWindowTitleHidden;
  // Allow dragging from the toolbar / titlebar area without a custom NSView
  // that would swallow mouse events meant for buttons.
  self.mainWindow.movableByWindowBackground = YES;
  // Let behind-window glass (sidebar/panels) sample the desktop for real
  // translucency / Liquid Glass vibrancy.
  self.mainWindow.opaque = NO;
  self.mainWindow.backgroundColor = NSColor.clearColor;
  [self.mainWindow setFrameAutosaveName:@"SoulMainWindow"];
  self.mainWindow.minSize = NSMakeSize(720, 480);

  // Build the SwiftUI root (sidebar + omnibox + web content) and host it.
  NSViewController* root = [SoulRoot makeRootViewController];
  self.mainWindow.contentViewController = root;

  [self.mainWindow center];
  [self.mainWindow makeKeyAndOrderFront:nil];
  [NSApp activateIgnoringOtherApps:YES];
}

/// Helper: add a menu item whose action lives on SoulRoot (class methods).
static void addSoulMenuItem(NSMenu* menu, NSString* title, SEL action, NSString* key) {
  NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:key];
  item.target = [SoulRoot class];
  [menu addItem:item];
}

// Build a standard macOS menu bar. The Edit menu's Cut/Copy/Paste/Select-All
// route to the first responder, which is how clipboard works inside CEF web
// text fields.
- (void)buildMainMenu {
  NSMenu* mainMenu = [[NSMenu alloc] init];

  // App menu.
  NSMenuItem* appItem = [[NSMenuItem alloc] init];
  [mainMenu addItem:appItem];
  NSMenu* appMenu = [[NSMenu alloc] init];
  [appMenu addItemWithTitle:@"About Soul"
                     action:@selector(orderFrontStandardAboutPanel:)
              keyEquivalent:@""];
  [appMenu addItem:[NSMenuItem separatorItem]];
  addSoulMenuItem(appMenu, @"Settings…", @selector(openSettings), @",");
  [appMenu addItem:[NSMenuItem separatorItem]];
  [appMenu addItemWithTitle:@"Hide Soul"
                     action:@selector(hide:)
              keyEquivalent:@"h"];
  [appMenu addItemWithTitle:@"Quit Soul"
                     action:@selector(terminate:)
              keyEquivalent:@"q"];
  appItem.submenu = appMenu;

  // File menu.
  NSMenuItem* fileItem = [[NSMenuItem alloc] init];
  [mainMenu addItem:fileItem];
  NSMenu* fileMenu = [[NSMenu alloc] initWithTitle:@"File"];
  addSoulMenuItem(fileMenu, @"New Tab", @selector(newTab), @"t");
  // Capital "T" -> Cmd-Shift-T (AppKit folds the Shift in automatically).
  addSoulMenuItem(fileMenu, @"Reopen Closed Tab", @selector(reopenTab), @"T");
  [fileMenu addItem:[NSMenuItem separatorItem]];
  addSoulMenuItem(fileMenu, @"Open Location…", @selector(openLocation), @"l");
  [fileMenu addItem:[NSMenuItem separatorItem]];
  addSoulMenuItem(fileMenu, @"Close Tab", @selector(closeCurrentTab), @"w");
  [fileMenu addItem:[NSMenuItem separatorItem]];
  addSoulMenuItem(fileMenu, @"Print…", @selector(printPage), @"p");
  fileItem.submenu = fileMenu;

  // Edit menu -- standard responder actions (clipboard for web fields).
  NSMenuItem* editItem = [[NSMenuItem alloc] init];
  [mainMenu addItem:editItem];
  NSMenu* editMenu = [[NSMenu alloc] initWithTitle:@"Edit"];
  [editMenu addItemWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:@"z"];
  [editMenu addItemWithTitle:@"Redo" action:@selector(redo:) keyEquivalent:@"Z"];
  [editMenu addItem:[NSMenuItem separatorItem]];
  [editMenu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
  [editMenu addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];
  [editMenu addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];
  [editMenu addItemWithTitle:@"Select All"
                      action:@selector(selectAll:)
               keyEquivalent:@"a"];
  [editMenu addItem:[NSMenuItem separatorItem]];
  addSoulMenuItem(editMenu, @"Find…", @selector(findInPage), @"f");
  addSoulMenuItem(editMenu, @"Find Next", @selector(findNext), @"g");
  // Capital "G" -> Cmd-Shift-G (find previous).
  addSoulMenuItem(editMenu, @"Find Previous", @selector(findPrevious), @"G");
  editItem.submenu = editMenu;

  // View menu.
  NSMenuItem* viewItem = [[NSMenuItem alloc] init];
  [mainMenu addItem:viewItem];
  NSMenu* viewMenu = [[NSMenu alloc] initWithTitle:@"View"];
  addSoulMenuItem(viewMenu, @"Reload", @selector(reload), @"r");
  // Capital "R" -> Cmd-Shift-R (reload, bypassing the cache).
  addSoulMenuItem(viewMenu, @"Force Reload", @selector(forceReload), @"R");
  addSoulMenuItem(viewMenu, @"Stop", @selector(stop), @".");
  [viewMenu addItem:[NSMenuItem separatorItem]];
  // Bound to "=" (not "+") so the bare Cmd-= that users actually press fires
  // it, without requiring Shift. Displays as ⌘=.
  addSoulMenuItem(viewMenu, @"Zoom In", @selector(zoomIn), @"=");
  addSoulMenuItem(viewMenu, @"Zoom Out", @selector(zoomOut), @"-");
  addSoulMenuItem(viewMenu, @"Actual Size", @selector(resetZoom), @"0");
  [viewMenu addItem:[NSMenuItem separatorItem]];
  // Cmd-S toggles the tab sidebar (the default modifier mask is Command).
  // NB: the action is intentionally NOT named toggleSidebar: -- that selector
  // collides with AppKit's built-in NSSplitViewController.toggleSidebar:, which
  // a responder in the SwiftUI/CEF chain claims and validates as disabled,
  // greying out the item. A unique name routes it straight to us.
  addSoulMenuItem(viewMenu, @"Toggle Sidebar", @selector(toggleSidebar), @"s");
  addSoulMenuItem(viewMenu, @"Command Palette", @selector(toggleLauncher), @"k");
  [viewMenu addItem:[NSMenuItem separatorItem]];
  // Cmd-Opt-I -> Developer Tools, matching Chrome/Safari's Inspect shortcut.
  NSMenuItem* devItem =
      [[NSMenuItem alloc] initWithTitle:@"Developer Tools"
                                 action:@selector(toggleDevTools)
                          keyEquivalent:@"i"];
  devItem.target = [SoulRoot class];
  devItem.keyEquivalentModifierMask =
      NSEventModifierFlagCommand | NSEventModifierFlagOption;
  [viewMenu addItem:devItem];
  viewItem.submenu = viewMenu;

  // History menu.
  NSMenuItem* historyItem = [[NSMenuItem alloc] init];
  [mainMenu addItem:historyItem];
  NSMenu* historyMenu = [[NSMenu alloc] initWithTitle:@"History"];
  addSoulMenuItem(historyMenu, @"Back", @selector(goBack), @"[");
  addSoulMenuItem(historyMenu, @"Forward", @selector(goForward), @"]");
  [historyMenu addItem:[NSMenuItem separatorItem]];
  // Capital "H" -> Cmd-Shift-H (avoids clobbering the app-level Hide on Cmd-H).
  addSoulMenuItem(historyMenu, @"Home", @selector(goHome), @"H");
  historyItem.submenu = historyMenu;

  // Window menu.
  NSMenuItem* windowItem = [[NSMenuItem alloc] init];
  [mainMenu addItem:windowItem];
  NSMenu* windowMenu = [[NSMenu alloc] initWithTitle:@"Window"];
  [windowMenu addItemWithTitle:@"Minimize"
                        action:@selector(performMiniaturize:)
                 keyEquivalent:@"m"];
  [windowMenu addItemWithTitle:@"Zoom"
                        action:@selector(performZoom:)
                 keyEquivalent:@""];
  [windowMenu addItem:[NSMenuItem separatorItem]];
  [windowMenu addItemWithTitle:@"Show All Windows"
                        action:@selector(arrangeInFront:)
                 keyEquivalent:@""];
  windowItem.submenu = windowMenu;

  // Tools menu (Roadmap features).
  NSMenuItem* toolsItem = [[NSMenuItem alloc] init];
  [mainMenu addItem:toolsItem];
  NSMenu* toolsMenu = [[NSMenu alloc] initWithTitle:@"Tools"];
  addSoulMenuItem(toolsMenu, @"Share Current Page", @selector(shareCurrentPage), @"");
  [toolsMenu addItem:[NSMenuItem separatorItem]];
  addSoulMenuItem(toolsMenu, @"Toggle HTTP Inspector", @selector(toggleHTTPInspector), @"");
  addSoulMenuItem(toolsMenu, @"Toggle Terminal Sidebar", @selector(toggleTerminalSidebar), @"");
  addSoulMenuItem(toolsMenu, @"Open Cookie & Storage Editor", @selector(openCookieEditor), @"");
  [toolsMenu addItem:[NSMenuItem separatorItem]];
  addSoulMenuItem(toolsMenu, @"Run Page Speed Telemetry", @selector(runPageSpeedTelemetry), @"");
  addSoulMenuItem(toolsMenu, @"Scan Web Assets", @selector(scanWebAssets), @"");
  [toolsMenu addItem:[NSMenuItem separatorItem]];
  addSoulMenuItem(toolsMenu, @"Run Anti-Phishing Scan", @selector(runAntiPhishingScan), @"");
  [toolsMenu addItem:[NSMenuItem separatorItem]];
  addSoulMenuItem(toolsMenu, @"Capture Page to Clipboard", @selector(capturePageToClipboard), @"");
  addSoulMenuItem(toolsMenu, @"Archive Page for Offline", @selector(archiveCurrentPage), @"");
  addSoulMenuItem(toolsMenu, @"Detect Video Streams", @selector(detectStreams), @"");
  addSoulMenuItem(toolsMenu, @"Create Web App", @selector(createWebAppFromCurrentTab), @"");
  [toolsMenu addItem:[NSMenuItem separatorItem]];
  addSoulMenuItem(toolsMenu, @"Toggle Annotation Mode", @selector(toggleAnnotationMode), @"");
  addSoulMenuItem(toolsMenu, @"Toggle Local File Server", @selector(toggleLocalFileServer), @"");
  addSoulMenuItem(toolsMenu, @"Show RSS Reader", @selector(showRSSReader), @"");
  [toolsMenu addItem:[NSMenuItem separatorItem]];
  addSoulMenuItem(toolsMenu, @"Open LLM Configurator", @selector(openLLMConfigurator), @"");
  toolsItem.submenu = toolsMenu;

  // Import menu (Migration).
  NSMenuItem* importItem = [[NSMenuItem alloc] init];
  [mainMenu addItem:importItem];
  NSMenu* importMenu = [[NSMenu alloc] initWithTitle:@"Import"];
  addSoulMenuItem(importMenu, @"Import from Chrome", @selector(importFromChrome), @"");
  addSoulMenuItem(importMenu, @"Import from Safari", @selector(importFromSafari), @"");
  addSoulMenuItem(importMenu, @"Import from Arc", @selector(importFromArc), @"");
  importItem.submenu = importMenu;

  // Help menu.
  NSMenuItem* helpItem = [[NSMenuItem alloc] init];
  [mainMenu addItem:helpItem];
  NSMenu* helpMenu = [[NSMenu alloc] initWithTitle:@"Help"];
  addSoulMenuItem(helpMenu, @"Onboarding Tour", @selector(startOnboarding), @"");
  addSoulMenuItem(helpMenu, @"Set Soul as Default Browser", @selector(promptDefaultBrowser), @"");
  helpItem.submenu = helpMenu;

  NSApp.mainMenu = mainMenu;
}

@end
