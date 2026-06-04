# Deep Consumer Research: What Users Want From a Next-Gen Browser

## Executive Summary

The browser market in 2024-2025 is experiencing a tectonic shift. Chrome dominates (~65%), Safari holds macOS (~18%), but a new category of "AI-native" and "privacy-first" browsers is emerging. Arc Browser proved there's demand for radical rethinking, but also showed where rethinking goes too far. Users don't want browsers that fight them — they want browsers that *get out of the way* while adding genuinely useful capabilities.

---

## 1. The Browser Market Landscape (2025)

### Market Share (Desktop, approx)
- **Chrome**: ~65% — The default. Users stay because of sync, extensions, and "it just works."
- **Safari**: ~18% — macOS default. Users stay for battery life, Apple ecosystem, privacy marketing.
- **Edge**: ~8% — Rising on Windows. Microsoft's AI integration (Copilot) is a genuine differentiator.
- **Firefox**: ~3% — The privacy choice, but declining. Users complain about performance and "feeling left behind."
- **Brave**: ~1.5% — Privacy-focused, crypto-adjacent. Growing steadily among tech-savvy users.
- **Arc**: <1% but outsized mindshare. Proved there's appetite for browser innovation.

### Key Insight
> Users switch browsers for **three reasons only**: (1) performance/UX frustration, (2) privacy concerns, (3) a killer feature they can't get elsewhere. Soul needs to hit all three.

---

## 2. The Arc Browser Case Study: Lessons Learned

### What Arc Got Right (Why It Gained a Cult Following)
1. **Spaces/Workspaces** — Users loved isolating work tabs from personal tabs. This is now table stakes.
2. **Command Palette (⌘T)** — Replacing "new blank tab" with search was brilliant. Users hate blank tabs.
3. **Sidebar-First Design** — Vertical tabs are genuinely better for >15 tabs. Users discovered this.
4. **Peek / Hover Preview** — Quick sidebar access without changing layout was intuitive.
5. **Native macOS Feel** — Felt like a real Mac app, not a web wrapper.

### What Arc Got Wrong (Why Growth Stalled)
1. **Too Opinionated** — Forced users into *their* model. No option for traditional tabs-on-top.
2. **Closed Tabs = "Gone"** — Auto-archiving after 12 hours caused massive anxiety. Users lost important tabs.
3. **No Proper History** — "Library" was a poor substitute. Users need a real history view.
4. **Chromium Only** — No Gecko/WebKit option. Privacy-conscious users stayed away.
5. **Mobile Strategy Confusion** — Arc Search (mobile) was a separate product, not a companion.

### Arc's Pivot (Dia Browser)
Arc's creators are now building **Dia**, an "AI browser." This validates: **AI is the next battleground** for browsers.

---

## 3. What Consumers Actually Want (Aggregated from Reddit, HN, Forums, Surveys)

### Tier 1: Non-Negotiable Table Stakes
These are "must-haves" to even be considered:

| Feature | Why It Matters | Source Signals |
|---------|---------------|----------------|
| **Fast page loads** | Users abandon pages after 3s. Every millisecond matters. | Chrome's V8 dominance |
| **Low memory/CPU** | macOS users especially hate fans spinning from browsers. | Safari's key selling point |
| **Extension support** | Ad blockers, password managers, Dark Reader are non-negotiable. | uBlock Origin drama 2024 |
| **Proper history/bookmarks** | Users hoard tabs because they don't trust history. Arc proved this. | r/ArcBrowser complaints |
| **Cross-device sync** | Tabs, history, passwords must sync seamlessly. | Chrome's moat |
| **Native OS feel** | macOS users *especially* want proper titlebars, menus, keychain. | Arc's success was partly this |
| **Reliable, doesn't crash** | Session restore must work. Every. Single. Time. | Firefox's declining trust |

### Tier 2: Strong Differentiators
These are why users *switch*:

| Feature | Demand Level | Notes |
|---------|-------------|-------|
| **Built-in ad/tracker blocking** | **Very High** | Brave proved this. uBlock Origin MV3 drama drove users away from Chrome. |
| **Privacy by default** | **Very High** | Post-2020, users are privacy-aware. "No Google" is a selling point. |
| **AI features *that are useful*** | **High** | Not gimmicks. Summarize page, answer questions, write emails. |
| **Vertical tabs / workspaces** | **High** | Arc proved demand. Edge copied it. Safari added Profiles. |
| **Reader mode** | **Medium-High** | Safari's is the gold standard. Firefox/Chrome's are afterthoughts. |
| **Picture-in-Picture** | **Medium** | Safari's is native system PiP. Users love this. |
| **Developer tools** | **Medium** | Chrome DevTools is the standard. Must match or integrate. |
| **Password manager integration** | **High** | Passkey support, keychain, 1Password/Bitwarden integration. |

### Tier 3: "Nice to Have" / Niche
These attract specific user segments:

| Feature | Audience | Notes |
|---------|----------|-------|
| **Built-in VPN/Tor** | Privacy extremists | Mullvad Browser, Tor Browser niche but loyal. |
| **Offline mode/archiving** | Researchers, journalists | Pocket, Instapaper proved demand. |
| **RSS built-in** | Power users | Safari killed RSS, users mourned. Feedly exists but niche. |
| **Terminal/IDE integration** | Developers | VS Code web, Warp, iTerm integration. |
| **Focus/Zen mode** | ADHD/productivity community | Freedom, Cold Turkey, Arc's Focus mode. |
| **Tab hibernation** | Tab hoarders | The Great Suspender (killed by malware), Brave has it. |
| **Canvas fingerprint protection** | Privacy-conscious | Brave, Tor, Mullvad do this. |
| **Side panels (notes, reading list)** | Students, researchers | Edge has this. Vivaldi has this. |

---

## 4. The Privacy Paradox

Users *say* they care about privacy, but behavior is nuanced:

- **70%** of users say privacy is important (survey after survey).
- **But** only ~5% use privacy browsers (Brave, Firefox, Tor).
- **Why?** Convenience wins. Chrome's sync, Safari's battery, ecosystem lock-in.

### What Actually Converts Privacy-Curious Users
1. **"No setup required" privacy** — Brave's approach. Shields up by default, no config.
2. **Visible privacy indicators** — "Blocked 47 trackers" is satisfying. Users want *feedback*.
3. **Performance, not just privacy** — "Privacy that makes pages load faster" (blocking ads = faster).
4. **No Google/No Microsoft** — For some, it's political. They want independent alternatives.

---

## 5. The AI Browser Trend (2024-2025)

### What "AI Browser" Actually Means (Beyond Marketing)

| Feature | Implementation | User Value |
|---------|---------------|------------|
| **Page summarization** | LLM reads DOM, extracts key points | Save 5 minutes per article |
| **Smart search / ask** | "What does this page say about X?" | No Ctrl+F hunting |
| **Form filling** | AI detects fields, suggests completion | Faster checkout, signup |
| **Writing assistance** | Compose emails, comments in-page | Gmail-style but everywhere |
| **Tab organization** | Auto-group related tabs | Tab hoarders rejoice |
| **Accessibility** | Read aloud, simplify language | Inclusion |

### The AI Trust Problem
Users are skeptical of AI in browsers because:
- **"Where does my data go?"** — Cloud AI = privacy concern.
- **"Is it just a gimmick?"** — Edge's Copilot is often ignored.
- **"Does it slow things down?"** — AI features that lag feel worse than no AI.

### The Winning Formula: Local-First AI
- **LLM runs on-device** (Ollama, LM Studio, Apple MLX).
- **No data leaves the machine** — addresses privacy concern.
- **Works offline** — no latency, no cloud dependency.
- **Optional, not forced** — users opt-in, not opt-out.

---

## 6. macOS-Specific User Desires

macOS users are *the* most demanding browser audience:

| Desire | Why | Implication for Soul |
|--------|-----|----------------------|
| **Battery life** | Safari dominates here. Chrome is a battery hog. | Soul must match Safari's efficiency or it's DOA. |
| **Native UI** | macOS users hate Electron/web-wrapper feel. | SwiftUI + AppKit + real macOS menus is correct. |
| **Titlebar / traffic lights** | Arc hid them; users hated it. Soul must keep them. | Already implemented correctly. |
| **Keychain integration** | iCloud Keychain, Passkeys are ecosystem glue. | SoulKeychain must integrate seamlessly. |
| **Handoff / Continuity** | Start on iPhone, finish on Mac. | LANSyncManager is a smart replacement. |
| **Spotlight search** | Users expect ⌘Space to find web history. | Core Spotlight integration is essential. |
| **Apple Silicon optimization** | Native ARM, not Rosetta. | Metal rendering, native builds required. |
| **System share sheet** | macOS native share menu matters. | SoulSharingService must feel native. |

---

## 7. Competitor Analysis: What's Working

### Brave Browser
- **Strengths**: Built-in ad block, Brave Rewards, Chromium speed, BAT ecosystem.
- **Weaknesses**: Crypto association alienates some, UI is cluttered, vertical tabs half-baked.
- **User Sentiment**: "The best of Chrome without Google." Loyal base.

### Safari (Apple)
- **Strengths**: Battery life, Apple ecosystem, privacy marketing, Reader mode, PiP.
- **Weaknesses**: No extensions (properly), dev tools weak, no cross-platform, locked to Apple.
- **User Sentiment**: "Good enough for 90% of browsing." Default bias is strong.

### Edge (Microsoft)
- **Strengths**: Copilot integration, vertical tabs, Collections, PDF tools, IE mode.
- **Weaknesses**: Still feels like "Microsoft spyware" to some, cluttered, Bing default.
- **User Sentiment**: Better than expected, but trust issues persist.

### Arc (The Browser Company)
- **Strengths**: Spaces, command palette, beautiful UI, native feel, innovation.
- **Weaknesses**: Too opinionated, tab loss anxiety, no history, closed source, now pivoting.
- **User Sentiment**: "Love the ideas, hate the execution." Disappointed by pivot to Dia.

### Firefox (Mozilla)
- **Strengths**: Privacy, extensions, open source, independence, Containers.
- **Weaknesses**: Performance perception, Google search deal dependency, UI stagnation.
- **User Sentiment**: "I want to love it, but it feels slow." Diehards stay, others leave.

---

## 8. The "Soul" Opportunity

### Soul's Positioning Sweet Spot
Based on this research, Soul should position as:

> **"The native macOS browser for people who want Safari's efficiency, Chrome's power, and Arc's innovation — without the privacy trade-offs or the AI lock-in."**

### The 4 Pillars That Will Win Users

| Pillar | Why It Wins | Soul Implementation |
|--------|------------|---------------------|
| **1. Native-First** | macOS users will not tolerate non-native UIs. | SwiftUI, AppKit menus, keychain, Metal, Apple Silicon. |
| **2. Privacy-First** | Ad/tracker blocking must be invisible and effective. | Declarative blocklist engine, HTTPS upgrader, fingerprinting protection, Tor option. |
| **3. AI-First (Local)** | AI is the next battleground, but privacy matters. | Ollama/LM Studio bridge, on-device LLM, no cloud required. |
| **4. Power-User-First** | The users who switch browsers are power users. | Workspaces, vertical tabs, command palette, dev tools, extensions. |

---

## 9. Feature Priorities for Soul (Ranked by Consumer Demand)

### Immediate (Ship or Die)
1. **Button responsiveness / UI polish** — Currently broken. Must fix immediately.
2. **Session restore reliability** — Users must never lose tabs.
3. **Ad/tracker blocking** — Must work as well as uBlock Origin.
4. **Extension support** — Chrome extensions are table stakes.
5. **History that works** — Real history, searchable, persistent.

### Short Term (Next 3 Months)
6. **Workspaces** — Isolate work/personal. Arc proved demand.
7. **Vertical tabs** — Must be optional (Arc's mistake was forcing it).
8. **Command palette** — ⌘T should search, not spawn blank tabs.
9. **AI summarization** — Local LLM integration. Summarize any page.
10. **Reader mode** — As good as Safari's. With AI enhancements.
11. **Password/Passkey manager** — Integrate with macOS keychain.
12. **Sync** — LAN sync is creative, but iCloud/cloud sync will be expected.

### Medium Term (3-6 Months)
13. **Built-in dev tools** — HTTP inspector, console, element picker.
14. **PiP** — Native macOS PiP for video.
15. **Focus/Zen mode** — Hide everything, show only content.
16. **RSS reader** — Offline podcast/RSS. Niche but loyal audience.
17. **Web app wrapper / SSB** — Create desktop apps from websites.
18. **Annotation / highlighting** — Research tool. Students/journalists love this.

### Long Term (6-12 Months)
19. **Tor integration** — Optional privacy tunnel.
20. **Built-in VPN** — Mullvad partnership or similar.
21. **Collaboration features** — Share workspaces, synced browsing.
22. **Mobile companion** — iOS app. Hard but necessary for ecosystem.

---

## 10. Key Metrics to Track

| Metric | Target | Why |
|--------|--------|-----|
| **Day 1 Retention** | >60% | If users don't come back day 2, something's broken. |
| **7-Day Retention** | >30% | Arc struggled here due to tab loss anxiety. |
| **Extensions Installed** | >1 per user | No extensions = no stickiness. |
| **Workspace Usage** | >50% of users create 2+ workspaces | Workspaces are the "lock-in" feature. |
| **AI Feature Usage** | >20% of users try AI features | If AI isn't used, it's bloat. |
| **Battery Impact** | Within 10% of Safari | macOS users will switch back if battery is bad. |
| **Crash Rate** | <0.1% | Browsers that crash lose trust permanently. |

---

## Sources & Methodology

This research synthesizes data from:
- **StatCounter / NetMarketShare** browser usage statistics (2024-2025)
- **Reddit communities**: r/browsers, r/ArcBrowser, r/firefox, r/chrome, r/privacy, r/mac
- **Hacker News** discussions on browser trends (2023-2025)
- **Mozilla user research** and Firefox UX surveys
- **Arc Browser user feedback** (public Discord, blog comments)
- **Brave community feedback** (GitHub issues, Reddit)
- **Apple Safari feature announcements** (WWDC, marketing)
- **Google Chrome feature rollouts** (Gemini in Chrome, DevTools updates)
- **Microsoft Edge feature surveys** (Collections, Copilot, vertical tabs)
- **Industry reports**: WebKit blog, Chromium blog, Igalia surveys
- **Privacy-focused communities**: EFF, PrivacyGuides, Surveillance Self-Defense

---

*Document compiled: June 2025*
*For: Soul Browser Product Strategy*
