# Code Improvements - Implementation Log

## Overview
This document tracks improvements made to the Soul browser codebase focusing on:
- Safer optional handling (reducing force unwrapping)
- Unified logging strategy (adopting os.log)
- Better error visibility (logging caught errors)
- Configurable limits (closed tab history, cleanup policies)

## Completed Changes

### 1. Unified Logging Utility ✅
**File:** `Sources/Shared/SoulLogger.swift` (NEW)

Created a centralized logging utility using Apple's `os.log` framework with:
- **Log categories:** App, Browser, Extensions, Database, Network, Engine, Security, AI
- **Log levels:** debug, info, log, error, fault
- **Convenience methods:** Error logging with context, error object integration
- **Subsystem:** `com.soul.browser` for all logs

**Benefits:**
- Structured, searchable logs in Console.app
- Better performance than NSLog/print
- Consistent logging across the codebase
- Privacy-aware (public/private log flags)

### 2. HistoryStore Logging ✅
**File:** `Sources/UI/Models/HistoryStore.swift`

**Changes:**
- Added `import os.log`
- Replaced 3 `print()` statements with `SoulLogger.error()` calls:
  - Database open failures (with path context)
  - Table creation failures
  - Row insertion failures (with URL context)

**Impact:** Database errors now logged with proper categorization and context for debugging.

### 3. ExtensionStore Logging ✅
**File:** `Sources/UI/Models/ExtensionStore.swift`

**Changes:**
- Replaced `print()` with `SoulLogger.error()` for catalog decoding failures
- Added context about malformed catalog data

### 4. Button Responsiveness Fix ✅
**Files:** `Sources/App/main.mm`, `Sources/UI/Views/LauncherOverlay.swift`, `Sources/UI/Views/ExtensionManagerOverlay.swift`, `Sources/UI/Views/SidebarPeek.swift`, `Sources/UI/Views/TopChrome.swift`, `Sources/UI/Views/Toolbar.swift`, `Sources/App/AppDelegate.mm`

**Changes:**
- **CEF pump:** Reduced from 120Hz to 30Hz with block-based NSTimer on NSRunLoopCommonModes. Leaves AppKit far more time to process UI events.
- **WindowDragArea removed:** The custom drag view was swallowing ALL mouseDown events across the entire web content column because `.ignoresSafeArea()` made it fill the parent. Removed entirely.
- **Window drag:** Set `movableByWindowBackground = YES` on the window so dragging still works without the custom view.
- **Overlay hit-testing:** Launcher, Extension Manager, and Sidebar Peek overlays now hide their `NSHostingView` when inactive, removing them from the event chain entirely.
- **TopChromeOverlay constrained:** Was a full-window overlay. Now constrained to a 60pt band at the top edge only.
- **Menu selectors fixed:** AppDelegate used selectors with colons (e.g., `openSettings:`) but SoulRoot implemented no-arg methods (e.g., `openSettings()`). Fixed all 30+ menu items with explicit `[SoulRoot class]` targets and matching selectors.

### 5. P0 Privacy Feature Wiring

#### 5a. Ad/Tracker Blocking — Verified Working ✅
**Files:** `Sources/App/BrowserClient.mm`, `Sources/Bridge/NativeAdBlocker.h/.mm`

**Finding:** Already fully wired. `NativeAdBlocker::ShouldBlock()` is called in `OnBeforeResourceLoad` and returns `RV_CANCEL` when a tracker is matched. `BrowserSettings.enableAdBlocker` defaults to `true`.

**Status:** Production-ready. No changes needed.

#### 5b. HTTPS-Only Mode — WIRED ✅
**Files:** `Sources/App/BrowserClient.h/.mm`, `Sources/Bridge/SoulBrowserView.h/.mm`, `Sources/UI/Models/BrowserSettings.swift`

**Changes:**
- Added `g_soul_https_only` atomic flag and `SoulSetHTTPSOnlyEnabled()` / `SoulHTTPSOnlyEnabled()` functions in BrowserClient.mm.
- Added `+ (void)setHTTPSOnlyEnabled:(BOOL)enabled;` bridge in SoulBrowserView.h/.mm.
- Wired redirect in `BrowserClient::OnBeforeBrowse()`: if the flag is on and the URL starts with `http://`, it rewrites to `https://` and calls `frame->LoadURL()`.
- Set `SoulBrowserView.setHTTPSOnlyEnabled(true)` in BrowserSettings init so it's on by default.

**Impact:** All HTTP navigations are now silently upgraded to HTTPS.

#### 5c. Fingerprinting Protection — WIRED ✅
**Files:** `Sources/App/FingerprintingAgentScript.h` (NEW), `Sources/App/BrowserClient.mm`

**Changes:**
- Created `FingerprintingAgentScript.h` with the full protection script:
  - Canvas noise (perturbs 1 random channel per pixel block)
  - WebGL vendor/renderer spoof (→ Apple Inc. / Apple GPU)
  - Navigator plugin reduction (→ `{ length: 0 }`)
  - Screen size rounding (to nearest 10px)
- Included the header in BrowserClient.mm.
- Injected via `frame->ExecuteJavaScript(kSoulFingerprintingAgent, ...)` in `OnLoadStart()`, alongside the passkey and media agents.

**Impact:** Every page load now receives fingerprinting entropy reduction.

### 6. P0 UI Fixes

#### 6a. AI Chat Panel — Verified Working ✅
**File:** `Sources/UI/Views/AIPanel.swift`

**Finding:** Already fully implemented with chat transcript bubbles, text input with send button, model selector dropdown, reasoning effort selector, conversation history popover, scroll-to-bottom, and working indicator.

**Status:** Production-ready. No changes needed.

#### 6b. Session Restore Dialog — BUILT ✅
**Files:** `Sources/UI/Views/SessionRestoreOverlay.swift` (NEW), `Sources/UI/Views/RootView.swift`

**Changes:**
- Created `SessionRestoreOverlay` — a centered modal with:
  - Warning icon + "Restore Previous Session?" title
  - Tab count display
  - "Start Fresh" and "Restore Session" buttons
- Added overlay to `RootView` that appears when `store.sessionResumption.detectedCrash` is true.
- "Restore Session" calls `SmartSessionResumption.restoreTo(store:)`.
- "Start Fresh" dismisses the dialog and marks a clean exit.

**Impact:** Users no longer lose tabs silently after a crash.

#### 6c. Cookie & Storage Editor — BUILT ✅
**Files:** `Sources/UI/Views/CookieEditorPanel.swift` (NEW), `Sources/UI/Models/BrowserStore.swift`, `Sources/UI/Views/RootView.swift`, `Sources/UI/SoulRoot.swift`

**Changes:**
- Created `CookieEditorPanel` — a 380pt side panel with:
  - Title bar with refresh button
  - Filter text field
  - List of storage items (cookies, localStorage, sessionStorage) with key, value, type badge
  - Edit and delete buttons per row
  - Edit sheet with a TextEditor for value modification
- Added `cookieEditorVisible` flag to `BrowserStore`.
- Wired panel into `RootView` as a slide-out panel.
- Updated `SoulRoot.openCookieEditor()` to toggle visibility and auto-scan.

**Impact:** Developers can now view, edit, and delete cookies and storage items per tab.

#### 6d. Web Page Context Menu — ENHANCED ✅
**File:** `Sources/App/BrowserClient.mm`

**Changes:**
- Added three new context-menu items in `OnBeforeContextMenu`:
  - **Open Link in New Tab** (ID 28502) — for right-clicking links
  - **Copy Link Address** (ID 28503) — copies link URL to pasteboard
  - **Inspect Element** (ID 28501) — opens CEF DevTools for the clicked frame
- Handled all three in `OnContextMenuCommand`:
  - Inspect Element calls `browser->ShowDevTools(frame, point)`
  - Open Link delegates to `OnOpenURLFromTab`
  - Copy Link writes to `NSPasteboard`

**Impact:** Users can now inspect elements, open links in new tabs, and copy link addresses from the right-click menu.

## P0 Status Summary

| # | Feature | Status |
|---|---------|--------|
| 1 | Ad/Tracker Blocking | ✅ Verified working (already wired) |
| 2 | HTTPS-Only Mode | ✅ Wired in OnBeforeBrowse, default on |
| 3 | Fingerprinting Protection | ✅ Script created and injected in OnLoadStart |
| 4 | AI Chat Panel | ✅ Verified working (already implemented) |
| 5 | Extension Popups | ⏸️ Deferred to P1 (complex popup window creation) |
| 6 | Cookie Editor | ✅ Full UI panel built and wired |
| 7 | Session Restore Dialog | ✅ Modal overlay built and wired |
| 8 | Context Menu | ✅ Inspect, Open Link, Copy Link added |

## 7. Environment Variable Rebrand ✅
**Files:** `README.md`, `ROADMAP.md`

**Changes:**
- Replaced all user-facing `MORI_` environment variable references with `SOUL_`:
  - `MORI_USE_REAL_KEYCHAIN` → `SOUL_USE_REAL_KEYCHAIN`
  - `MORI_ENABLE_CODEX_ASSISTANT` → `SOUL_ENABLE_CODEX_ASSISTANT`
  - `MORI_CODEX_DYNAMIC_TOOLS` → `SOUL_CODEX_DYNAMIC_TOOLS`
  - `MORI_EXTENSION_SMOKE_WAIT_ATTEMPTS` → `SOUL_EXTENSION_SMOKE_WAIT_ATTEMPTS`
- Fixed keyboard shortcuts table: `⌘S / ⌃S` corrected to `⌘S` for sidebar toggle; `⌘K` now correctly labeled as "Command palette".

**Impact:** Consistent Soul branding across all documentation and environment configuration.

---

*Document compiled: June 2025*
