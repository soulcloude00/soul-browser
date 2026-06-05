import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { User, Check, AlertCircle } from 'lucide-react'

const stories = [
  {
    id: 'developer',
    persona: 'The Extension Hoarder',
    role: 'Full Stack Developer',
    scenario: 'You have 45 tabs open, uBlock active, 3 developer extensions, and need to inspect CSS grid layouts.',
    options: {
      chrome: {
        label: 'Chrome',
        outcome: 'Your Mac fans are screaming. The activity monitor shows helper processes consuming 4.2GB of RAM. Manifest V3 has crippled uBlock, letting subtle trackers through, and the battery will drain in 2.5 hours.',
        metrics: { ram: '4.2 GB', battery: 'Poor', extensions: 'Weakened' },
        status: 'warning'
      },
      safari: {
        label: 'Safari',
        outcome: 'Your battery life is excellent, and your Mac is silent. But your password manager is sluggish, your key Chrome extensions are not available in the App Store, and the Developer Tools lack the modern layout debugger you need.',
        metrics: { ram: '1.2 GB', battery: 'Excellent', extensions: 'Incompatible' },
        status: 'warning'
      },
      soul: {
        label: 'Soul Browser',
        outcome: 'Silent, fast, and fully loaded. Built on native SwiftUI/AppKit chrome, the process runs directly on Metal with 40% less GPU footprint than Chrome. You get uBlock and full Chrome extensions since it embeds CEF, while drawing less power than Electron.',
        metrics: { ram: '1.6 GB', battery: 'Great', extensions: 'Full Support' },
        status: 'success'
      }
    }
  },
  {
    id: 'researcher',
    persona: 'The Privacy Advocate',
    role: 'Journalist & Writer',
    scenario: 'You are researching sensitive geopolitical documents and want to find a specific article you read on Tuesday.',
    options: {
      chrome: {
        label: 'Chrome',
        outcome: 'Google records your browser history to build your ad profile. You search your history, but the search is basic text-only. You cannot find the page unless you remember the exact words in the title.',
        metrics: { tracking: 'High Telemetry', search: 'Exact Match', storage: 'Google Cloud' },
        status: 'warning'
      },
      safari: {
        label: 'Safari',
        outcome: 'Better privacy, but history is synced to iCloud. Finding the article requires scrolling through days of history items. There is no natural language support, and canvas tracking is only partially mitigated.',
        metrics: { tracking: 'Moderate', search: 'Scroll History', storage: 'iCloud Sync' },
        status: 'warning'
      },
      soul: {
        label: 'Soul Browser',
        outcome: 'Complete data isolation. History is stored in a local SQLite vector database. You search by typing: "that article about renewable microgrids with the green chart", and local semantic matching finds it instantly. Zero data leaves your machine.',
        metrics: { tracking: 'Zero Telemetry', search: 'Local Semantic AI', storage: 'On-device SQLite' },
        status: 'success'
      }
    }
  },
  {
    id: 'ai_user',
    persona: 'The AI Power User',
    role: 'Product Designer',
    scenario: 'You want to summarize a complex 8,000-word product specification and write a quick email reply from it.',
    options: {
      chrome: {
        label: 'Chrome/Edge',
        outcome: 'You open a side panel that uploads the page content to external servers. It costs a monthly subscription, experiences cloud latency, and raises flags with your company\'s security policies.',
        metrics: { privacy: 'Cloud Leak', cost: '$20/mo', speed: '1.8s (Cloud)' },
        status: 'warning'
      },
      safari: {
        label: 'Safari',
        outcome: 'No integrated AI panel. You copy the entire page manually, open a separate ChatGPT tab, paste the text, wait for the response, and copy it back. Disconnected and tedious.',
        metrics: { privacy: 'Manual Copy', cost: 'Free/Paid', speed: 'Manual flow' },
        status: 'warning'
      },
      soul: {
        label: 'Soul Browser',
        outcome: 'You tap ⌘K and call the AI sidebar. A local Codex assistant summarizes the page in 0.4s. It runs entirely on-device via Ollama or LM Studio. You highlight a sentence, click "Smart Rewrite", and Soul automates it. All free and 100% private.',
        metrics: { privacy: '100% Local', cost: 'Free', speed: '0.4s (Local)' },
        status: 'success'
      }
    }
  }
]

export default function StoryComparison() {
  const [activeStoryIdx, setActiveStoryIdx] = useState(0)
  const [selectedBrowser, setSelectedBrowser] = useState<'chrome' | 'safari' | 'soul'>('soul')

  const activeStory = stories[activeStoryIdx]
  const currentOutcome = activeStory.options[selectedBrowser]

  return (
    <section id="story-comparison" className="py-24 md:py-32 relative overflow-hidden bg-transparent border-t border-zinc-900/10 dark:border-zinc-50/10">
      <div className="max-w-5xl mx-auto px-6 relative z-10">
        <div className="text-center mb-16">
          <span className="flex items-center justify-center gap-1.5 px-3 py-1 rounded-full bg-orange-600/10 text-orange-700 dark:text-orange-500 w-fit mx-auto text-[10px] font-mono uppercase tracking-[0.18em] mb-4">
            <span className="w-1.5 h-1.5 rounded-full bg-orange-600 animate-pulse" />
            A Day in the Life
          </span>
          <h2 className="font-display font-semibold text-4xl md:text-5xl tracking-[-0.03em] leading-[1.02] text-zinc-900 dark:text-zinc-100 mb-5 text-balance">
            The Tales of <span className="text-orange-600">Three Browsers</span>
          </h2>
          <p className="text-base text-zinc-600 dark:text-zinc-400 max-w-xl mx-auto leading-[1.6]">
            Features tell only half the story. Select a scenario below to see how Soul Browser behaves in everyday work compared to the alternatives.
          </p>
        </div>

        <div className="grid lg:grid-cols-[1.1fr_0.9fr] gap-8 items-start">
          {/* Left: Interactive Story card */}
          <div className="space-y-6">
            {/* Story selector tabs */}
            <div className="flex flex-wrap gap-2 p-1.5 rounded-2xl bg-zinc-900/[0.04] dark:bg-zinc-50/[0.04] border border-zinc-900/10 dark:border-zinc-50/10">
              {stories.map((story, idx) => (
                <button
                  key={story.id}
                  onClick={() => {
                    setActiveStoryIdx(idx)
                    // keep soul selected or reset
                  }}
                  className={`flex-1 min-w-[140px] flex items-center justify-center gap-2.5 px-4 py-3 rounded-xl text-[13px] font-medium transition-all duration-300 cursor-pointer ${
                    activeStoryIdx === idx
                      ? 'bg-zinc-900 text-white dark:bg-white dark:text-[#0c0b09] shadow-md'
                      : 'text-zinc-500 dark:text-zinc-400 hover:text-zinc-800 dark:hover:text-zinc-200 hover:bg-zinc-900/[0.02] dark:hover:bg-white/[0.02]'
                  }`}
                >
                  <User size={13} />
                  <span>{story.persona}</span>
                </button>
              ))}
            </div>

            {/* Story Details Card */}
            <div className="panel p-6 rounded-2xl border border-zinc-900/10 dark:border-zinc-50/10">
              <div className="flex items-center gap-3 mb-4">
                <div className="w-9 h-9 rounded-xl bg-orange-600/10 border border-orange-600/20 flex items-center justify-center">
                  <User size={15} className="text-orange-600" />
                </div>
                <div>
                  <h3 className="text-sm font-semibold text-zinc-900 dark:text-zinc-100">{activeStory.persona}</h3>
                  <p className="text-xs text-zinc-500 dark:text-zinc-400">{activeStory.role}</p>
                </div>
              </div>

              <div className="p-4 rounded-xl bg-zinc-900/[0.03] dark:bg-white/[0.02] border border-zinc-900/[0.06] dark:border-white/[0.05] mb-6">
                <div className="text-[11px] font-mono text-zinc-400 dark:text-zinc-500 uppercase tracking-wider mb-1.5">Scenario</div>
                <p className="text-[13px] text-zinc-700 dark:text-zinc-300 leading-relaxed font-sans">{activeStory.scenario}</p>
              </div>

              {/* Browser Choice Selector */}
              <div className="space-y-4">
                <div className="text-[11px] font-mono text-zinc-400 dark:text-zinc-500 uppercase tracking-wider">Choose a browser to test:</div>
                <div className="grid grid-cols-3 gap-2">
                  {(['chrome', 'safari', 'soul'] as const).map((b) => (
                    <button
                      key={b}
                      onClick={() => setSelectedBrowser(b)}
                      className={`relative py-3 rounded-xl border text-[13px] font-medium transition-all duration-300 cursor-pointer ${
                        selectedBrowser === b
                          ? b === 'soul'
                            ? 'border-orange-600/50 bg-orange-600/10 text-orange-700 dark:text-orange-400 shadow-[0_0_12px_-4px_rgba(239,99,7,0.3)]'
                            : 'border-zinc-500 bg-zinc-500/10 text-zinc-800 dark:text-zinc-300'
                          : 'border-zinc-900/10 dark:border-zinc-50/10 hover:border-zinc-900/20 dark:hover:border-zinc-50/20 text-zinc-500 hover:text-zinc-800 dark:hover:text-zinc-200'
                      }`}
                    >
                      {b === 'soul' ? 'Soul' : b === 'chrome' ? 'Chrome' : 'Safari'}
                      {selectedBrowser === b && (
                        <span className={`absolute -top-1 -right-1 w-2.5 h-2.5 rounded-full ${b === 'soul' ? 'bg-orange-600' : 'bg-zinc-500'}`} />
                      )}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Right: Outcome details */}
          <div className="relative">
            <div className="panel p-6 rounded-2xl border border-zinc-900/10 dark:border-zinc-50/10 h-full flex flex-col justify-between min-h-[350px]">
              <div>
                <div className="flex items-center gap-2 mb-4 pb-3 border-b border-zinc-900/10 dark:border-zinc-50/10">
                  {currentOutcome.status === 'success' ? (
                    <div className="w-5 h-5 rounded-full bg-emerald-500/15 border border-emerald-500/30 flex items-center justify-center text-emerald-600">
                      <Check size={11} />
                    </div>
                  ) : (
                    <div className="w-5 h-5 rounded-full bg-amber-500/15 border border-amber-500/30 flex items-center justify-center text-amber-600">
                      <AlertCircle size={11} />
                    </div>
                  )}
                  <span className="text-[12px] font-mono uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
                    Outcome: {selectedBrowser === 'soul' ? 'Soul Solution' : `${currentOutcome.label} behavior`}
                  </span>
                </div>

                <AnimatePresence mode="wait">
                  <motion.div
                    key={`${activeStoryIdx}-${selectedBrowser}`}
                    initial={{ opacity: 0, y: 8 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -8 }}
                    transition={{ duration: 0.25 }}
                    className="space-y-4"
                  >
                    <p className="text-[13.5px] leading-relaxed text-zinc-800 dark:text-zinc-200 font-sans">
                      {currentOutcome.outcome}
                    </p>
                  </motion.div>
                </AnimatePresence>
              </div>

              {/* Outcome Specific Metrics */}
              <div className="mt-8 pt-4 border-t border-zinc-900/10 dark:border-zinc-50/10">
                <div className="text-[10px] font-mono text-zinc-400 dark:text-zinc-500 uppercase tracking-wider mb-3">Diagnostic metrics</div>
                <div className="grid grid-cols-3 gap-2">
                  {Object.entries(currentOutcome.metrics).map(([key, val]) => (
                    <div key={key} className="p-2.5 rounded-xl bg-zinc-900/[0.03] dark:bg-white/[0.02] border border-zinc-900/[0.06] dark:border-white/[0.05]">
                      <div className="text-[10.5px] font-semibold text-zinc-900 dark:text-zinc-100 truncate">{val}</div>
                      <div className="text-[9.5px] text-zinc-500 dark:text-zinc-400 uppercase font-mono mt-0.5 tracking-tight truncate">{key}</div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
