import { motion } from 'framer-motion'
import { ArrowRight, Cpu, Sparkles, Shield } from 'lucide-react'

export default function Hero() {
  return (
    <section className="relative pt-36 pb-28 md:pt-48 md:pb-40 overflow-hidden">
      <div className="max-w-6xl mx-auto px-6 relative z-10">
        <div className="grid lg:grid-cols-2 gap-20 items-center">
          {/* Left: Text */}
          <div className="space-y-7">
            <motion.div
              initial={{ opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
              className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full glass text-[13px] text-orange-300/80"
            >
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-orange-400 opacity-40" />
                <span className="relative inline-flex rounded-full h-2 w-2 bg-orange-400" />
              </span>
              <span>Active development</span>
            </motion.div>

            <motion.h1
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.1 }}
              className="text-[2.75rem] md:text-[3.5rem] font-bold tracking-[-0.03em] leading-[1.05] text-white"
            >
              The browser your{' '}
              <span className="gradient-text">Mac</span> deserves
            </motion.h1>

            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              className="text-[15px] md:text-base text-slate-400 max-w-lg leading-[1.7]"
            >
              Native macOS AI browser built with SwiftUI and a real Chromium engine.
              Vertical tabs, local AI, Liquid Glass — no compromises.
            </motion.p>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.3 }}
              className="flex flex-wrap items-center gap-3 pt-1"
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
              <a
                href="#architecture"
                className="inline-flex items-center gap-2 px-5 py-2.5 text-[14px] text-slate-300 hover:text-white font-medium rounded-xl transition-colors border border-white/[0.06] hover:border-white/10 bg-white/[0.02]"
              >
                <span>Explore</span>
              </a>
            </motion.div>

            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.8, delay: 0.5 }}
              className="flex items-center gap-5 pt-2"
            >
              {[
                { icon: Cpu, label: 'CEF 148' },
                { icon: Shield, label: 'Local AI' },
                { icon: Sparkles, label: 'Liquid Glass' },
              ].map((item) => (
                <div key={item.label} className="flex items-center gap-1.5 text-[12px] text-slate-500">
                  <item.icon size={12} className="text-orange-400/70" />
                  <span>{item.label}</span>
                </div>
              ))}
            </motion.div>
          </div>

          {/* Right: Browser Mockup */}
          <motion.div
            initial={{ opacity: 0, y: 40, scale: 0.97 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            transition={{ duration: 0.9, delay: 0.2, ease: [0.22, 1, 0.36, 1] }}
            className="relative"
          >
            {/* Glow behind */}
            <div className="absolute -inset-8 bg-gradient-to-tr from-orange-500/10 via-violet-500/5 to-transparent blur-3xl rounded-[3rem]" />

            {/* Browser window */}
            <div className="relative rounded-2xl overflow-hidden border border-white/[0.08] shadow-2xl shadow-black/60 bg-[#0c0c12]">
              {/* macOS title bar */}
              <div className="flex items-center gap-2 px-4 py-3 bg-[#14141a] border-b border-white/[0.04]">
                <div className="flex gap-2">
                  <div className="w-[11px] h-[11px] rounded-full bg-[#ff5f56] border border-black/20" />
                  <div className="w-[11px] h-[11px] rounded-full bg-[#ffbd2e] border border-black/20" />
                  <div className="w-[11px] h-[11px] rounded-full bg-[#27c93f] border border-black/20" />
                </div>
                <div className="flex-1 flex justify-center">
                  <div className="bg-white/[0.04] rounded-md px-4 py-1 text-[11px] text-slate-500 flex items-center gap-2 min-w-[180px] justify-center">
                    <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10c.5 0 1 0 1.5-.1"/><path d="M2 12h20"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                    <span className="opacity-70">soul.dev</span>
                    <span className="ml-auto opacity-30 text-[10px]">⌘L</span>
                  </div>
                </div>
                <div className="w-[55px]" />
              </div>

              {/* Browser body */}
              <div className="flex h-[340px]">
                {/* Vertical tab strip */}
                <div className="w-[52px] border-r border-white/[0.04] flex flex-col items-center py-2.5 gap-1.5 bg-[#0a0a0f]">
                  {[
                    { icon: 'S', active: true, color: 'bg-orange-500/15 text-orange-400 border-orange-500/20' },
                    { icon: 'G', active: false },
                    { icon: 'X', active: false },
                  ].map((tab, i) => (
                    <div key={i} className={`w-[34px] h-[34px] rounded-lg flex items-center justify-center text-[11px] font-medium transition-all ${
                      tab.active ? tab.color + ' border' : 'text-slate-600 hover:text-slate-400 hover:bg-white/[0.03]'
                    }`}>
                      {tab.icon}
                    </div>
                  ))}
                  <div className="w-[34px] h-[34px] rounded-lg flex items-center justify-center text-slate-600 hover:text-slate-400 cursor-pointer">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M5 12h14"/><path d="M12 5v14"/></svg>
                  </div>
                  <div className="mt-auto w-[34px] h-[34px] rounded-lg flex items-center justify-center text-slate-700">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="3"/><path d="M12 2v4"/><path d="M12 18v4"/><path d="m4.93 4.93 2.83 2.83"/><path d="m16.24 16.24 2.83 2.83"/><path d="M2 12h4"/><path d="M18 12h4"/><path d="m4.93 19.07 2.83-2.83"/><path d="m16.24 7.76 2.83-2.83"/></svg>
                  </div>
                </div>

                {/* Content area */}
                <div className="flex-1 flex flex-col relative overflow-hidden">
                  {/* Toolbar */}
                  <div className="h-9 border-b border-white/[0.03] flex items-center px-3 gap-3">
                    <div className="flex gap-1">
                      <div className="w-6 h-5 rounded bg-white/[0.03]" />
                      <div className="w-6 h-5 rounded bg-white/[0.03]" />
                    </div>
                    <div className="h-4 w-px bg-white/[0.04]" />
                    <div className="flex gap-1.5">
                      <div className="w-5 h-5 rounded bg-white/[0.03]" />
                      <div className="w-5 h-5 rounded bg-white/[0.03]" />
                      <div className="w-5 h-5 rounded bg-white/[0.03]" />
                    </div>
                    <div className="ml-auto flex items-center gap-2">
                      <div className="w-20 h-4 rounded bg-white/[0.03]" />
                    </div>
                  </div>

                  {/* Page content */}
                  <div className="flex-1 p-5 space-y-3">
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

                  {/* AI Assistant floating panel */}
                  <div className="absolute bottom-3 right-3 w-[220px] glass rounded-xl p-3 border border-orange-500/[0.08]">
                    <div className="flex items-center gap-2 mb-2">
                      <div className="w-5 h-5 rounded-full bg-gradient-to-br from-orange-400/20 to-orange-600/10 flex items-center justify-center">
                        <Sparkles size={10} className="text-orange-400" />
                      </div>
                      <span className="text-[11px] font-medium text-slate-300">Soul</span>
                      <span className="text-[10px] text-slate-600 ml-auto">AI</span>
                    </div>
                    <div className="space-y-1.5">
                      <div className="h-1.5 w-full bg-white/[0.04] rounded-full" />
                      <div className="h-1.5 w-2/3 bg-white/[0.04] rounded-full" />
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Reflected glow */}
            <div className="absolute -bottom-4 left-1/2 -translate-x-1/2 w-[80%] h-8 bg-orange-500/10 blur-2xl rounded-full" />
          </motion.div>
        </div>
      </div>
    </section>
  )
}
