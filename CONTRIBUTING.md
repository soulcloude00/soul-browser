# Contributing to Soul

Thank you for your interest in making Soul better. This guide covers how to set up your development environment, build the project, and submit changes.

## Development Setup

### Requirements

- **macOS 26+** (Soul uses macOS 26 Liquid Glass APIs)
- **Xcode 26+**
- **arm64 Mac** (Apple Silicon)
- Homebrew packages: `xcodegen`, `cmake`

```bash
brew install xcodegen cmake
```

### Clone & Build

```bash
git clone https://github.com/soulcloude00/soul-browser.git
cd soul-browser
./run.sh        # Generate project, build Debug, and launch
```

The first build compiles `libcef_dll_wrapper` from the bundled CEF 148 distribution. Subsequent builds are incremental.

```bash
./run.sh --release   # Release build
./run.sh --gen       # Regenerate Soul.xcodeproj only
```

### Project Structure

```
Sources/
  App/       CEF browser process, AppKit window, menu bar
  Bridge/    SoulBrowserView (ObjC NSView wrapping one CEF browser)
  Helper/    CEF sub-process entry points (renderer, GPU, etc.)
  Shared/    Cross-cutting utilities (SoulLogger, schemes)
  UI/        SwiftUI chrome: Theme/, Models/, Views/, SoulRoot
  Resources/ Plists, entitlements, home.html
Scripts/     Build helpers, CEF framework embedding
third_party/cef/   CEF 148 distribution + built wrapper
```

## Environment Variables

| Variable | Purpose |
|---|---|
| `SOUL_ENABLE_CODEX_ASSISTANT` | Set to `0` to disable the local Codex AI panel (enabled by default) |
| `SOUL_CODEX_DYNAMIC_TOOLS` | Set to `1` to enable dynamic browser automation tools for Codex |
| `SOUL_USE_REAL_KEYCHAIN` | Set to `1` to use real Apple Keychain instead of the mock store |
| `SOUL_START_URL` | Override the URL opened on launch |

## Code Style

- **Swift:** Follow standard Swift style. Use `SoulLogger` instead of `print()`.
- **ObjC/C++:** Match existing indentation and brace style.
- **No force unwraps** in new Swift code. Use `guard let` or `if let`.

## Testing Extension Changes

```bash
./script/build_and_run.sh --verify-extension-smoke
```

This installs fixture extensions and exercises the Chromium extension API surface end-to-end.

## Pull Requests

1. Fork the repo and create a feature branch.
2. Make your changes with clear commit messages.
3. Ensure the project builds with `./run.sh`.
4. Open a PR with a description of what changed and why.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
