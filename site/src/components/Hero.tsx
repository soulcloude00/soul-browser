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
    <section className="relative pt-32 pb-24 md:pt-40 md:pb-32 overflow-hidden">
      <div className="max-w-6xl mx-auto px-6 relative z-10">
        <div className="grid lg:grid-cols-2 gap-16 items-center">
          {/* Left: Text */}
          <div className="space-y-6">
            <motion.div
              initial={{ opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
              className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full glass text-[12px] text-orange-300/70"
            >
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-orange-400 opacity-30" />
                <span className="relative inline-flex rounded-full h-2 w-2 bg-orange-400" />
              </span>
              <span>Active development</span>
            </motion.div>

            <motion.h1
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.1 }}
              className="text-[2.5rem] md:text-[3.25rem] font-bold tracking-[-0.03em] leading-[1.05] text-white"
            >
              The browser your{' '}
              <span className="gradient-text">Mac</span> deserves
            </motion.h1>

            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              className="text-[15px] text-slate-400 max-w-md leading-[1.7]"
            >
              Native macOS AI browser. SwiftUI + Chromium via CEF.
              Vertical tabs, local AI, Liquid Glass.
            </motion.p>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.3 }}
              className="flex flex-wrap items-center gap-3"
            >
              <a
                href="https://github.com/soulcloude/mori-browser"
                target="_blank"
                rel="noopener noreferrer"
                className="group inline-flex items-center gap-2 px-5 py-2.5 bg-white text-black text-[14px] font-medium rounded-xl transition-all duration-300 hover:bg-white/90"
              >
                <span>Get Started</span>
                <ArrowRight size={14} className="group-hover:translate-x-0.5 transition-transform" />
              </a>
              <button
                onClick={() => {
                  const evt = new KeyboardEvent('keydown', { metaKey: true, key: 'k' })
                  window.dispatchEvent(evt)
                }}
                className="inline-flex items-center gap-2 px-5 py-2.5 text-[14px] text-slate-300 hover:text-white font-medium rounded-xl transition-colors border border-white/[0.06] hover:border-white/10 bg-white/[0.02]"
              >
                <Command size={13} />
                <span>Try ⌘K</span>
              </button>
            </motion.div>

            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.8, delay: 0.5 }}
              className="flex items-center gap-5"
            >
              {[
                { icon: Cpu, label: 'CEF 148' },
                { icon: Shield, label: 'Local AI' },
                { icon: Sparkles, label: 'Liquid Glass' },
              ].map((item) => (
                <div key={item.label} className="flex items-center gap-1.5 text-[12px] text-slate-600">
                  <item.icon size={12} className="text-orange-400/50" />
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
            <div className="absolute -inset-6 bg-gradient-to-tr from-orange-500/[0.06] via-transparent to-transparent blur-3xl rounded-[3rem]" />

            <div className="relative rounded-2xl overflow-hidden border border-white/[0.06] shadow-2xl shadow-black/60 bg-[#0c0c12]">
              {/* macOS title bar */}
              <div className="flex items-center gap-2 px-4 py-3 bg-[#14141a] border-b border-white/[0.04]">
                <div className="flex gap-2">
                  <div className="w-[11px] h-[11px] rounded-full bg-[#ff5f56] border border-black/20 hover:brightness-110 cursor-pointer" />
                  <div className="w-[11px] h-[11px] rounded-full bg-[#ffbd2e] border border-black/20 hover:brightness-110 cursor-pointer" />
                  <div className="w-[11px] h-[11px] rounded-full bg-[#27c93f] border border-black/20 hover:brightness-110 cursor-pointer" />
                </div>
                <div className="flex-1 flex justify-center">
                  <div className="bg-white/[0.03] rounded-md px-4 py-1 text-[11px] text-slate-500 flex items-center gap-2 min-w-[200px] justify-center">
                    <Globe size={10} />
                    <span className="opacity-60">{browserTabs.find(t => t.id === activeTab)?.url}</span>
                    <span className="ml-auto opacity-20 text-[10px]">⌘L</span>
                  </div>
                </div>
                <div className="w-[55px]" />
              </div>

              <div className="flex h-[320px]">
                {/* Vertical tab strip — interactive */}
                <div className="w-[52px] border-r border-white/[0.04] flex flex-col items-center py-2.5 gap-1 bg-[#0a0a0f]">
                  {browserTabs.map((tab) => (
                    <button
                      key={tab.id}
                      onClick={() => setActiveTab(tab.id)}
                      className={`w-[34px] h-[34px] rounded-lg flex items-center justify-center text-[11px] font-medium transition-all cursor-pointer ${
                        activeTab === tab.id
                          ? 'bg-orange-500/15 text-orange-400 border border-orange-500/20'
                          : 'text-slate-600 hover:text-slate-400 hover:bg-white/[0.03]'
                      }`}
                      title={tab.label}
                    >
                      {tab.icon}
                    </button>
                  ))}
                  <div className="w-[34px] h-[34px] rounded-lg flex items-center justify-center text-slate-700 hover:text-slate-500 cursor-pointer transition-colors">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M5 12h14"/><path d="M12 5v14"/></svg>
                  </div>
                  <div className="mt-auto w-[34px] h-[34px] rounded-lg flex items-center justify-center text-slate-700">
                    <Settings size={13} />
                  </div>
                </div>

                {/* Content area — changes with tab */}
                <div className="flex-1 flex flex-col relative overflow-hidden">
                  <div className="h-9 border-b border-white/[0.03] flex items-center px-3 gap-2">
                    <div className="flex gap-1">
                      <div className="w-5 h-5 rounded bg-white/[0.03]" />
                      <div className="w-5 h-5 rounded bg-white/[0.03]" />
                    </div>
                    <div className="h-3.5 w-px bg-white/[0.04]" />
                    <div className="flex gap-1">
                      <div className="w-4 h-4 rounded bg-white/[0.03]" />
                      <div className="w-4 h-4 rounded bg-white/[0.03]" />
                      <div className="w-4 h-4 rounded bg-white/[0.03]" />
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
                          <div className="space-y-3">
                            <div className="flex items-center gap-3">
                              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-orange-500/20 to-orange-600/5 border border-orange-500/10 flex items-center justify-center">
                                <span className="text-orange-400 text-sm font-bold">S</span>
                              </div>
                              <div className="space-y-1.5">
                                <div className="h-3 w-32 bg-white/[0.05] rounded" />
                                <div className="h-2 w-20 bg-white/[0.03] rounded" />
                              </div>
                            </div>
                            <div className="space-y-1.5 pt-1">
                              <div className="h-2 w-full bg-white/[0.02] rounded" />
                              <div className="h-2 w-[92%] bg-white/[0.02] rounded" />
                              <div className="h-2 w-[78%] bg-white/[0.02] rounded" />
                            </div>
                            <div className="grid grid-cols-3 gap-2.5 pt-1">
                              {[0, 1, 2].map((i) => (
                                <div key={i} className="aspect-[4/3] rounded-lg bg-gradient-to-br from-white/[0.03] to-white/[0.01] border border-white/[0.04]" />
                              ))}
                            </div>
                          </div>
                        )}
                        {activeTab === 'github' && (
                          <div className="space-y-3">
                            <div className="flex items-center gap-2">
                              <div className="w-6 h-6 rounded-full bg-white/[0.05] flex items-center justify-center">
                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-slate-500"><path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"/></svg>
                              </div>
                              <div className="h-3 w-40 bg-white/[0.05] rounded" />
                            </div>
                            <div className="space-y-2 pt-2">
                              <div className="h-8 w-full bg-white/[0.02] rounded-lg border border-white/[0.03]" />
                              <div className="h-8 w-full bg-white/[0.02] rounded-lg border border-white/[0.03]" />
                              <div className="h-8 w-[80%] bg-white/[0.02] rounded-lg border border-white/[0.03]" />
                            </div>
                          </div>
                        )}
                        {activeTab === 'docs' && (
                          <div className="space-y-2">
                            <div className="h-5 w-24 bg-white/[0.05] rounded mb-3" />
                            <div className="space-y-1.5">
                              <div className="h-2 w-full bg-white/[0.02] rounded" />
                              <div className="h-2 w-[95%] bg-white/[0.02] rounded" />
                              <div className="h-2 w-[88%] bg-white/[0.02] rounded" />
                              <div className="h-2 w-[70%] bg-white/[0.02] rounded" />
                            </div>
                            <div className="mt-3 p-3 rounded-lg bg-white/[0.02] border border-white/[0.03]">
                              <div className="h-2 w-full bg-white/[0.03] rounded" />
                              <div className="h-2 w-[90%] bg-white/[0.03] rounded mt-1.5" />
                            </div>
                          </div>
                        )}
                      </motion.div>
                    </AnimatePresence>

                    {/* AI Assistant floating panel */}
                    <div className="absolute bottom-3 right-3 w-[200px] glass rounded-xl p-3 border border-orange-500/[0.06]">
                      <div className="flex items-center gap-2 mb-2">
                        <div className="w-5 h-5 rounded-full bg-gradient-to-br from-orange-400/20 to-orange-600/10 flex items-center justify-center">
                          <Sparkles size={10} className="text-orange-400" />
                        </div>
                        <span className="text-[11px] font-medium text-slate-400">Soul</span>
                        <span className="text-[10px] text-slate-700 ml-auto">AI</span>
                      </div>
                      <div className="space-y-1.5">
                        <div className="h-1.5 w-full bg-white/[0.04] rounded-full" />
                        <div className="h-1.5 w-2/3 bg-white/[0.04] rounded-full" />
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="absolute -bottom-4 left-1/2 -translate-x-1/2 w-[80%] h-8 bg-orange-500/8 blur-2xl rounded-full" />
          </motion.div>
        </div>
      </div>
    </section>
  )
}
