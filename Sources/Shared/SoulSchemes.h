#pragma once

#include "include/cef_scheme.h"
#include "include/internal/cef_types.h"

namespace soul {

inline constexpr const char* kExtensionScheme = "soul-extension";

// Internal browser pages (the new-tab / home page) are served from this scheme
// so they read as native chrome — empty address bar, no file:// path — instead
// of a bundled file URL.
inline constexpr const char* kInternalScheme = "soul";

inline void RegisterCustomSchemes(CefRawPtr<CefSchemeRegistrar> registrar) {
  if (!registrar) {
    return;
  }
  registrar->AddCustomScheme(kExtensionScheme,
                             CEF_SCHEME_OPTION_STANDARD |
                                 CEF_SCHEME_OPTION_SECURE |
                                 CEF_SCHEME_OPTION_CORS_ENABLED |
                                 CEF_SCHEME_OPTION_CSP_BYPASSING |
                                 CEF_SCHEME_OPTION_FETCH_ENABLED);
  registrar->AddCustomScheme(kInternalScheme,
                             CEF_SCHEME_OPTION_STANDARD |
                                 CEF_SCHEME_OPTION_SECURE |
                                 CEF_SCHEME_OPTION_CORS_ENABLED |
                                 CEF_SCHEME_OPTION_FETCH_ENABLED);
}

}  // namespace soul
