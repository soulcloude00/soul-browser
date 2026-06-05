import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { ArrowRight, Cpu, Sparkles, Shield, Globe, Settings, Command, Database } from 'lucide-react'

const browserTabs = [
  { id: 'soul', icon: 'S', label: 'soul.dev', url: 'soul.dev' },
  { id: 'github', icon: 'G', label: 'github.com', url: 'github.com/soulcloude/mori-browser' },
  { id: 'dev', icon: 'D', label: 'Cookie Editor', url: 'devtools://storage-editor' },
]

export default function Hero() {
  const [activeTab, setActiveTab] = useState('soul')

  return (
    <section className="relative min-h-[100dvh] flex items-center pt-28 pb-20 overflow-hidden bg-transparent">
      <div className="max-w-6xl mx-auto px-6 relative z-10 w-full">
        <div className="grid lg:grid-cols-[1.05fr_0.95fr] gap-12 lg:gap-16 items-center">
          {/* Left: Text */}
          <div>
            <motion.div
              initial={{ opacity: 0, y: 12 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
              className="inline-flex items-center gap-2 mb-7 pl-2 pr-3 py-1 rounded-full glass"
            >
              <span className="flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-orange-600/10 text-[10px] font-mono uppercase tracking-[0.18em] text-orange-700 dark:text-orange-500">
                <span className="w-1.5 h-1.5 rounded-full bg-orange-600" />
                macOS Native
              </span>
              <span className="text-[12px] text-zinc-600 dark:text-zinc-400">Pure Swift + Metal Chromium</span>
            </motion.div>

            <motion.h1
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.08 }}
              className="font-display font-semibold text-[3.25rem] sm:text-6xl lg:text-7.5xl tracking-[-0.04em] leading-[0.95] text-zinc-900 dark:text-zinc-100 text-balance"
            >
              The browser your <span className="text-orange-600">Mac</span> deserves.
            </motion.h1>

            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.16 }}
              className="mt-7 text-base md:text-lg text-zinc-600 dark:text-zinc-400 max-w-md leading-[1.6]"
            >
              A native SwiftUI shell wrapping a real Chromium engine via Metal. Extension compatibility and developer tools, with 40% less memory and buttery 120Hz scrolling. No Electron, no cloud telemetry.
            </motion.p>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.24 }}
              className="mt-9 flex flex-wrap items-center gap-3"
            >
              <a
                href="https://github.com/soulcloude/mori-browser"
                target="_blank"
                rel="noopener noreferrer"
                className="group inline-flex items-center gap-2 px-6 py-3 bg-[#14130f] hover:bg-[#2a2822] text-[#f5f3ee] dark:bg-[#f5f3ee] dark:hover:bg-[#efece5] dark:text-[#1c1814] text-[15px] font-medium rounded-xl transition-all duration-300 active:scale-[0.98] focus:outline-none"
              >
                <span>Get the browser</span>
                <ArrowRight size={16} className="group-hover:translate-x-0.5 transition-transform" />
              </a>
              <button
                onClick={() => {
                  const evt = new KeyboardEvent('keydown', { metaKey: true, key: 'k' })
                  window.dispatchEvent(evt)
                }}
                className="inline-flex items-center gap-2 px-5 py-3 text-[15px] text-zinc-700 dark:text-zinc-300 hover:text-zinc-900 dark:hover:text-zinc-100 font-medium rounded-xl transition-colors border border-zinc-900/15 dark:border-white/15 hover:border-zinc-900/30 dark:hover:border-white/30 bg-white/40 dark:bg-white/5 active:scale-[0.98] focus:outline-none"
              >
                <Command size={15} />
                <span>Try ⌘K</span>
              </button>
            </motion.div>

            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.8, delay: 0.4 }}
              className="mt-10 flex items-center gap-6 border-t border-zinc-900/10 dark:border-white/10 pt-6"
            >
              {[
                { icon: Cpu, label: 'CEF 148 Engine' },
                { icon: Shield, label: 'On-Device AI' },
                { icon: Sparkles, label: 'Metal 120Hz' },
              ].map((item) => (
                <div key={item.label} className="flex items-center gap-2 text-[13px] text-zinc-500 dark:text-zinc-400 font-medium">
                  <item.icon size={14} strokeWidth={2} className="text-orange-600" />
                  <span>{item.label}</span>
                </div>
              ))}
            </motion.div>
          </div>

          {/* Right: Interactive Browser Mockup */}
          <motion.div
            initial={{ opacity: 0, y: 40, scale: 0.97 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            transition={{ duration: 0.9, delay: 0.2, ease: [0.22, 1, 0.36, 1] }}
            className="relative"
          >
            <div className="relative rounded-2xl overflow-hidden border border-zinc-900/10 dark:border-white/10 shadow-[0_30px_60px_-24px_rgba(20,19,15,0.35)] dark:shadow-[0_30px_60px_-24px_rgba(0,0,0,0.6)] bg-white dark:bg-[#1a1916] transition-colors duration-300">
              {/* macOS title bar */}
              <div className="flex items-center gap-2 px-4 py-3 bg-[#f0eee8] dark:bg-[#252320] border-b border-zinc-900/10 dark:border-white/10 transition-colors">
                <div className="flex gap-2">
                  <div className="w-[11px] h-[11px] rounded-full bg-[#ff5f56] hover:brightness-105 cursor-pointer" />
                  <div className="w-[11px] h-[11px] rounded-full bg-[#ffbd2e] hover:brightness-105 cursor-pointer" />
                  <div className="w-[11px] h-[11px] rounded-full bg-[#27c93f] hover:brightness-105 cursor-pointer" />
                </div>
                <div className="flex-1 flex justify-center">
                  <div className="bg-zinc-900/[0.05] dark:bg-white/[0.05] rounded-md px-4 py-1 text-[11px] text-zinc-500 dark:text-zinc-400 flex items-center gap-2 min-w-[200px] justify-center transition-colors">
                    <Globe size={10} />
                    <span className="font-mono">{browserTabs.find(t => t.id === activeTab)?.url}</span>
                    <span className="ml-auto opacity-40 text-[10px]">⌘L</span>
                  </div>
                </div>
                <div className="w-[55px]" />
              </div>

              <div className="flex h-[340px]">
                {/* Vertical tab strip - interactive sidebar (Right side in Soul browser by default!) */}
                {/* Content area */}
                <div className="flex-1 flex flex-col relative overflow-hidden bg-white dark:bg-[#151412] transition-colors">
                  {/* Internal browser controls */}
                  <div className="h-9 border-b border-zinc-900/[0.07] dark:border-white/[0.07] flex items-center px-3 gap-2 bg-[#faf9f6] dark:bg-[#1d1c1a] transition-colors">
                    <div className="flex gap-1">
                      <div className="w-5 h-5 rounded bg-zinc-900/[0.05] dark:bg-white/[0.05] flex items-center justify-center text-[10px] text-zinc-400">←</div>
                      <div className="w-5 h-5 rounded bg-zinc-900/[0.05] dark:bg-white/[0.05] flex items-center justify-center text-[10px] text-zinc-400">→</div>
                    </div>
                    <div className="h-3.5 w-px bg-zinc-900/10 dark:bg-white/10" />
                    <div className="flex gap-1 ml-auto">
                      <span className="text-[10px] text-emerald-600 dark:text-emerald-400 bg-emerald-500/10 px-1.5 py-0.5 rounded border border-emerald-500/20 font-mono flex items-center gap-1">
                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                        HTTPS
                      </span>
                    </div>
                  </div>

                  <div className="flex-1 relative overflow-y-auto">
                    <AnimatePresence mode="wait">
                      <motion.div
                        key={activeTab}
                        initial={{ opacity: 0, x: 10 }}
                        animate={{ opacity: 1, x: 0 }}
                        exit={{ opacity: 0, x: -10 }}
                        transition={{ duration: 0.2 }}
                        className="absolute inset-0 p-5 text-zinc-800 dark:text-zinc-200"
                      >
                        {activeTab === 'soul' && (
                          <div className="space-y-4">
                            <div className="flex items-center gap-3">
                              <div className="w-10 h-10 rounded-xl bg-orange-600/10 border border-orange-600/20 flex items-center justify-center">
                                <span className="text-orange-700 dark:text-orange-500 text-sm font-bold">S</span>
                              </div>
                              <div>
                                <div className="text-[13px] font-semibold text-zinc-900 dark:text-zinc-100">Soul Browser</div>
                                <div className="text-[11px] text-zinc-500 dark:text-zinc-400">The native macOS browser</div>
                              </div>
                            </div>
                            <p className="text-[11px] text-zinc-500 dark:text-zinc-400 leading-[1.6]">
                              A premium web browser built from the ground up for macOS. Replaces Electron memory overhead with native SwiftUI code, drawing framebuffers directly via CEF onto Metal.
                            </p>
                            <div className="grid grid-cols-3 gap-2">
                              {[
                                { k: 'GPU Memory', v: '-40%' },
                                { k: 'Scroll Rate', v: '120Hz' },
                                { k: 'AI Assistant', v: 'Local-Only' },
                              ].map((s) => (
                                <div key={s.k} className="rounded-lg bg-zinc-900/[0.03] dark:bg-white/[0.03] border border-zinc-900/[0.07] dark:border-white/[0.07] p-2 text-center">
                                  <div className="text-[13px] font-semibold text-orange-600 dark:text-orange-400 tabular-nums">{s.v}</div>
                                  <div className="text-[9px] text-zinc-500 dark:text-zinc-400 font-mono uppercase mt-0.5 tracking-tight">{s.k}</div>
                                </div>
                              ))}
                            </div>
                          </div>
                        )}
                        {activeTab === 'github' && (
                          <div className="space-y-3">
                            <div className="flex items-center gap-2">
                              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-zinc-700 dark:text-zinc-300"><path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"/></svg>
                              <span className="text-[12px] text-zinc-700 dark:text-zinc-300 font-mono">soulcloude / mori-browser</span>
                            </div>
                            <p className="text-[11px] text-zinc-500 dark:text-zinc-400 leading-[1.6]">Native macOS AI browser. SwiftUI + AppKit wrappers over Chromium via CEF.</p>
                            <div className="flex items-center gap-3 text-[10px] text-zinc-400 dark:text-zinc-500">
                              <span className="flex items-center gap-1"><span className="w-1.5 h-1.5 rounded-full bg-orange-600" />Swift / ObjC++</span>
                              <span className="tabular-nums">MIT License</span>
                            </div>
                            <div className="space-y-1 pt-1 font-mono text-[9.5px]">
                              {['Sources/UI/Theme/SoulLogger.swift', 'Sources/Bridge/SoulBrowserView.mm', 'Sources/Bridge/NativeAdBlocker.mm'].map((f) => (
                                <div key={f} className="flex items-center gap-2 px-2.5 py-1 rounded-md bg-zinc-900/[0.03] dark:bg-white/[0.03] border border-zinc-900/[0.06] dark:border-white/[0.06] text-zinc-600 dark:text-zinc-400">
                                  <span className="text-orange-600/70">{'</'}</span>{f}
                                </div>
                              ))}
                            </div>
                          </div>
                        )}
                        {activeTab === 'dev' && (
                          <div className="space-y-2.5">
                            <div className="flex items-center justify-between">
                              <div className="text-[12.5px] font-semibold text-zinc-900 dark:text-zinc-100 flex items-center gap-1.5">
                                <Database size={13} className="text-orange-600" />
                                <span>Cookie & Storage Editor</span>
                              </div>
                              <span className="text-[9px] font-mono uppercase bg-orange-600/10 text-orange-600 px-1.5 py-0.5 rounded">NEW</span>
                            </div>
                            <p className="text-[11px] text-zinc-500 dark:text-zinc-400 leading-[1.5]">
                              Soul includes a native 380pt side panel to directly view, filter, edit, and delete cookies/localStorage entries without heavy DevTools overlay.
                            </p>
                            <div className="border border-zinc-900/10 dark:border-white/10 rounded-lg overflow-hidden font-mono text-[10px] bg-zinc-900/[0.01] dark:bg-white/[0.01]">
                              <div className="grid grid-cols-[1fr_1.5fr_0.8fr] gap-2 p-1.5 bg-zinc-900/[0.04] dark:bg-white/[0.04] border-b border-zinc-900/10 dark:border-white/10 font-bold text-zinc-600 dark:text-zinc-400">
                                <span>Key</span>
                                <span>Value</span>
                                <span>Action</span>
                              </div>
                              <div className="divide-y divide-zinc-900/5 dark:divide-white/5">
                                <div className="grid grid-cols-[1fr_1.5fr_0.8fr] gap-2 p-1.5 text-zinc-500 dark:text-zinc-400">
                                  <span className="truncate">session_id</span>
                                  <span className="text-emerald-600 truncate font-semibold">a8f9d2...</span>
                                  <span className="text-orange-600 cursor-pointer hover:underline">Edit</span>
                                </div>
                                <div className="grid grid-cols-[1fr_1.5fr_0.8fr] gap-2 p-1.5 text-zinc-500 dark:text-zinc-400">
                                  <span className="truncate">theme</span>
                                  <span className="truncate">"dark"</span>
                                  <span className="text-orange-600 cursor-pointer hover:underline">Edit</span>
                                </div>
                              </div>
                            </div>
                          </div>
                        )}
                      </motion.div>
                    </AnimatePresence>
                  </div>
                </div>

                {/* Vertical Tab Strip - Native to Soul's layout on right-hand sidebar */}
                <div className="w-[52px] border-l border-zinc-900/10 dark:border-white/10 flex flex-col items-center py-2.5 gap-1.5 bg-[#f4f2ec] dark:bg-[#1a1916] transition-colors duration-300">
                  {browserTabs.map((tab) => (
                    <button
                      key={tab.id}
                      onClick={() => setActiveTab(tab.id)}
                      className={`w-[34px] h-[34px] rounded-lg flex flex-col items-center justify-center text-[10px] font-semibold transition-all cursor-pointer ${
                        activeTab === tab.id
                          ? 'bg-orange-600/10 dark:bg-orange-600/20 text-orange-700 dark:text-orange-400 border border-orange-600/25'
                          : 'text-zinc-400 dark:text-zinc-500 hover:text-zinc-700 dark:hover:text-zinc-300 hover:bg-zinc-900/[0.04] dark:hover:bg-white/[0.04]'
                      }`}
                      title={tab.label}
                    >
                      <span>{tab.icon}</span>
                      <span className="text-[7.5px] scale-90 tracking-tighter opacity-80">{tab.id === 'dev' ? 'Dev' : tab.id}</span>
                    </button>
                  ))}
                  <div className="w-[34px] h-[34px] rounded-lg flex items-center justify-center text-zinc-400 dark:text-zinc-500 hover:text-zinc-600 dark:hover:text-zinc-300 cursor-pointer transition-colors">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M5 12h14"/><path d="M12 5v14"/></svg>
                  </div>
                  <div className="mt-auto w-[34px] h-[34px] rounded-lg flex items-center justify-center text-zinc-400 dark:text-zinc-500 hover:text-zinc-600 dark:hover:text-zinc-300 cursor-pointer">
                    <Settings size={13} />
                  </div>
                </div>
              </div>
            </div>

            {/* Floating AI Panel Sidebar */}
            <div className="absolute -bottom-6 -left-6 w-[230px] rounded-xl p-3 bg-[#14130f] dark:bg-[#151412] border border-zinc-800 shadow-[0_12px_28px_-12px_rgba(20,19,15,0.6)]">
              <div className="flex items-center gap-2 mb-2">
                <div className="w-5 h-5 rounded-full bg-orange-500/15 border border-orange-500/30 flex items-center justify-center">
                  <Sparkles size={10} className="text-orange-400" />
                </div>
                <span className="text-[11px] font-medium text-zinc-200">Local Codex Assistant</span>
                <span className="text-[9px] text-emerald-400 ml-auto flex items-center gap-1 font-mono">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-ping" />
                  Local
                </span>
              </div>
              <p className="text-[10px] text-zinc-400 leading-[1.6]">
                "Analyzed this page. Upgraded to HTTPS-Only. Blocked 12 trackers. Canvas fingerprint noise injected."
              </p>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  )
}
