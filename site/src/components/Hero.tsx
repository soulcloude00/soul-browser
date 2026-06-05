import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { ArrowRight, Cpu, Sparkles, Shield, Globe, Settings, Command } from 'lucide-react'

const browserTabs = [
  { id: 'soul', icon: 'S', label: 'soul.dev', url: 'soul.dev' },
  { id: 'github', icon: 'G', label: 'github.com', url: 'github.com/soulcloude/mori-browser' },
  { id: 'docs', icon: 'D', label: 'docs', url: 'docs.soul.dev' },
]

export default function Hero() {
  const [activeTab, setActiveTab] = useState('soul')

  return (
    <section className="relative min-h-[100dvh] flex items-center pt-28 pb-20 overflow-hidden">
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
              <span className="flex items-center gap-1.5 px-2 py-0.5 rounded-full bg-orange-600/10 text-[10px] font-mono uppercase tracking-[0.18em] text-orange-700">
                <span className="w-1.5 h-1.5 rounded-full bg-orange-600" />
                macOS
              </span>
              <span className="text-[12px] text-zinc-600">A browser that runs AI on-device</span>
            </motion.div>

            <motion.h1
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.08 }}
              className="font-display font-semibold text-[3.25rem] sm:text-6xl lg:text-7xl tracking-[-0.04em] leading-[0.95] text-[#14130f] text-balance"
            >
              The browser your <span className="text-orange-600">Mac</span> deserves.
            </motion.h1>

            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.16 }}
              className="mt-7 text-lg text-zinc-600 max-w-md leading-[1.6]"
            >
              Native SwiftUI shell, a real Chromium engine, and a local AI assistant. No cloud, no Electron.
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
                className="group inline-flex items-center gap-2 px-6 py-3 bg-[#14130f] text-[#f5f3ee] text-[15px] font-medium rounded-xl transition-all duration-300 hover:bg-[#2a2822] active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-zinc-900/25 focus:ring-offset-2 focus:ring-offset-[#ece9e2]"
              >
                <span>Get the browser</span>
                <ArrowRight size={16} className="group-hover:translate-x-0.5 transition-transform" />
              </a>
              <button
                onClick={() => {
                  const evt = new KeyboardEvent('keydown', { metaKey: true, key: 'k' })
                  window.dispatchEvent(evt)
                }}
                className="inline-flex items-center gap-2 px-5 py-3 text-[15px] text-zinc-700 hover:text-[#14130f] font-medium rounded-xl transition-colors border border-zinc-900/15 hover:border-zinc-900/30 bg-white/40 active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-zinc-900/15 focus:ring-offset-2 focus:ring-offset-[#ece9e2]"
              >
                <Command size={15} />
                <span>Try ⌘K</span>
              </button>
            </motion.div>

            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.8, delay: 0.4 }}
              className="mt-10 flex items-center gap-6 border-t border-zinc-900/10 pt-6"
            >
              {[
                { icon: Cpu, label: 'CEF 148' },
                { icon: Shield, label: 'Local AI' },
                { icon: Sparkles, label: 'Liquid Glass' },
              ].map((item) => (
                <div key={item.label} className="flex items-center gap-2 text-[13px] text-zinc-500">
                  <item.icon size={14} strokeWidth={1.75} className="text-orange-600" />
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
            <div className="relative rounded-2xl overflow-hidden border border-zinc-900/10 shadow-[0_30px_60px_-24px_rgba(20,19,15,0.35)] bg-white">
              {/* macOS title bar */}
              <div className="flex items-center gap-2 px-4 py-3 bg-[#f0eee8] border-b border-zinc-900/10">
                <div className="flex gap-2">
                  <div className="w-[11px] h-[11px] rounded-full bg-[#ff5f56] hover:brightness-105 cursor-pointer" />
                  <div className="w-[11px] h-[11px] rounded-full bg-[#ffbd2e] hover:brightness-105 cursor-pointer" />
                  <div className="w-[11px] h-[11px] rounded-full bg-[#27c93f] hover:brightness-105 cursor-pointer" />
                </div>
                <div className="flex-1 flex justify-center">
                  <div className="bg-zinc-900/[0.05] rounded-md px-4 py-1 text-[11px] text-zinc-500 flex items-center gap-2 min-w-[200px] justify-center">
                    <Globe size={10} />
                    <span>{browserTabs.find(t => t.id === activeTab)?.url}</span>
                    <span className="ml-auto opacity-40 text-[10px]">⌘L</span>
                  </div>
                </div>
                <div className="w-[55px]" />
              </div>

              <div className="flex h-[320px]">
                {/* Vertical tab strip - interactive */}
                <div className="w-[52px] border-r border-zinc-900/10 flex flex-col items-center py-2.5 gap-1 bg-[#f4f2ec]">
                  {browserTabs.map((tab) => (
                    <button
                      key={tab.id}
                      onClick={() => setActiveTab(tab.id)}
                      className={`w-[34px] h-[34px] rounded-lg flex items-center justify-center text-[11px] font-medium transition-all cursor-pointer ${
                        activeTab === tab.id
                          ? 'bg-orange-600/10 text-orange-700 border border-orange-600/25'
                          : 'text-zinc-400 hover:text-zinc-700 hover:bg-zinc-900/[0.04]'
                      }`}
                      title={tab.label}
                    >
                      {tab.icon}
                    </button>
                  ))}
                  <div className="w-[34px] h-[34px] rounded-lg flex items-center justify-center text-zinc-400 hover:text-zinc-600 cursor-pointer transition-colors">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M5 12h14"/><path d="M12 5v14"/></svg>
                  </div>
                  <div className="mt-auto w-[34px] h-[34px] rounded-lg flex items-center justify-center text-zinc-400">
                    <Settings size={13} />
                  </div>
                </div>

                {/* Content area - changes with tab */}
                <div className="flex-1 flex flex-col relative overflow-hidden bg-white">
                  <div className="h-9 border-b border-zinc-900/[0.07] flex items-center px-3 gap-2">
                    <div className="flex gap-1">
                      <div className="w-5 h-5 rounded bg-zinc-900/[0.05]" />
                      <div className="w-5 h-5 rounded bg-zinc-900/[0.05]" />
                    </div>
                    <div className="h-3.5 w-px bg-zinc-900/10" />
                    <div className="flex gap-1">
                      <div className="w-4 h-4 rounded bg-zinc-900/[0.05]" />
                      <div className="w-4 h-4 rounded bg-zinc-900/[0.05]" />
                      <div className="w-4 h-4 rounded bg-zinc-900/[0.05]" />
                    </div>
                  </div>

                  <div className="flex-1 relative">
                    <AnimatePresence mode="wait">
                      <motion.div
                        key={activeTab}
                        initial={{ opacity: 0, x: 10 }}
                        animate={{ opacity: 1, x: 0 }}
                        exit={{ opacity: 0, x: -10 }}
                        transition={{ duration: 0.2 }}
                        className="absolute inset-0 p-5"
                      >
                        {activeTab === 'soul' && (
                          <div className="space-y-3.5">
                            <div className="flex items-center gap-3">
                              <div className="w-10 h-10 rounded-xl bg-orange-600/10 border border-orange-600/20 flex items-center justify-center">
                                <span className="text-orange-700 text-sm font-bold">S</span>
                              </div>
                              <div>
                                <div className="text-[13px] font-semibold text-zinc-900">Soul Browser</div>
                                <div className="text-[11px] text-zinc-500">The browser your Mac deserves</div>
                              </div>
                            </div>
                            <p className="text-[11px] text-zinc-500 leading-[1.7]">
                              A native macOS browser with a local AI assistant, vertical tabs, and a Chromium engine rendered through Metal.
                            </p>
                            <div className="grid grid-cols-3 gap-2">
                              {[
                                { k: 'GPU', v: '-40%' },
                                { k: 'Scroll', v: '120Hz' },
                                { k: 'AI', v: 'Local' },
                              ].map((s) => (
                                <div key={s.k} className="rounded-lg bg-zinc-900/[0.03] border border-zinc-900/[0.07] p-2">
                                  <div className="text-[13px] font-semibold text-zinc-800 tabular-nums">{s.v}</div>
                                  <div className="text-[10px] text-zinc-500">{s.k}</div>
                                </div>
                              ))}
                            </div>
                          </div>
                        )}
                        {activeTab === 'github' && (
                          <div className="space-y-3">
                            <div className="flex items-center gap-2">
                              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-zinc-700"><path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"/></svg>
                              <span className="text-[12px] text-zinc-700 font-mono">soulcloude / mori-browser</span>
                            </div>
                            <p className="text-[11px] text-zinc-500 leading-[1.6]">Native macOS AI browser. SwiftUI + Chromium via CEF.</p>
                            <div className="flex items-center gap-3 text-[10px] text-zinc-500">
                              <span className="flex items-center gap-1"><span className="w-2 h-2 rounded-full bg-orange-600" />Swift</span>
                              <span className="tabular-nums">128 stars</span>
                              <span className="tabular-nums">14 forks</span>
                            </div>
                            <div className="space-y-1.5 pt-1 font-mono text-[10px]">
                              {['src/SoulBrowserView.swift', 'cef/MetalRenderHandler.mm', 'ai/CodexBridge.swift'].map((f) => (
                                <div key={f} className="flex items-center gap-2 px-2.5 py-1.5 rounded-md bg-zinc-900/[0.03] border border-zinc-900/[0.07] text-zinc-600">
                                  <span className="text-zinc-400">{'</>'}</span>{f}
                                </div>
                              ))}
                            </div>
                          </div>
                        )}
                        {activeTab === 'docs' && (
                          <div className="space-y-2.5">
                            <div className="text-[13px] font-semibold text-zinc-900">Getting started</div>
                            <p className="text-[11px] text-zinc-500 leading-[1.7]">
                              Soul ships as a signed macOS app. Clone the repo, install CEF, and run the build script to launch.
                            </p>
                            <div className="rounded-lg bg-[#14130f] p-3 font-mono text-[10px] text-zinc-300 leading-relaxed">
                              <div><span className="text-orange-400">$</span> git clone soul.dev/repo</div>
                              <div><span className="text-orange-400">$</span> ./scripts/setup-cef.sh</div>
                              <div><span className="text-orange-400">$</span> open Soul.xcodeproj</div>
                            </div>
                            <div className="flex items-center gap-1.5 text-[10px] text-zinc-500">
                              <kbd className="px-1 rounded bg-zinc-900/[0.06] border border-zinc-900/10 font-mono">⌘K</kbd>
                              <span>opens the command palette</span>
                            </div>
                          </div>
                        )}
                      </motion.div>
                    </AnimatePresence>

                    {/* AI Assistant floating panel */}
                    <div className="absolute bottom-3 right-3 w-[210px] rounded-xl p-3 bg-[#14130f] shadow-[0_12px_28px_-12px_rgba(20,19,15,0.5)]">
                      <div className="flex items-center gap-2 mb-2">
                        <div className="w-5 h-5 rounded-full bg-orange-500/15 border border-orange-500/30 flex items-center justify-center">
                          <Sparkles size={10} className="text-orange-400" />
                        </div>
                        <span className="text-[11px] font-medium text-zinc-200">Soul</span>
                        <span className="text-[10px] text-zinc-500 ml-auto flex items-center gap-1"><span className="w-1.5 h-1.5 rounded-full bg-emerald-400" />on-device</span>
                      </div>
                      <p className="text-[10.5px] text-zinc-400 leading-[1.6]">Summarized this page in 0.4s. Ask me anything about it.</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>

          </motion.div>
        </div>
      </div>
    </section>
  )
}
