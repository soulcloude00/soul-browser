import { motion } from 'framer-motion'
import { ArrowRight, Cpu, Sparkles, Shield } from 'lucide-react'

export default function Hero() {
  return (
    <section className="relative pt-32 pb-20 md:pt-44 md:pb-32 overflow-hidden">
      <div className="max-w-7xl mx-auto px-6 relative z-10">
        <div className="grid lg:grid-cols-2 gap-16 items-center">
          <div className="space-y-8">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
              className="inline-flex items-center gap-2 px-4 py-2 rounded-full glass text-sm text-accent-300 border-accent-500/10"
            >
              <Sparkles size={14} />
              <span>Now in active development</span>
            </motion.div>

            <motion.h1
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.1 }}
              className="text-5xl md:text-7xl font-bold tracking-tight leading-[1.1]"
            >
              Browse with a{' '}
              <span className="gradient-text">Soul</span>
            </motion.h1>

            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              className="text-lg md:text-xl text-slate-400 max-w-xl leading-relaxed"
            >
              A native macOS AI browser. SwiftUI + AppKit chrome wrapping a real
              Chromium engine via CEF, with a built-in Codex assistant, vertical tabs,
              and Liquid Glass design.
            </motion.p>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.3 }}
              className="flex flex-wrap items-center gap-4"
            >
              <a
                href="https://github.com/soulcloude/mori-browser"
                target="_blank"
                rel="noopener noreferrer"
                className="group inline-flex items-center gap-2 px-6 py-3 bg-accent-500 hover:bg-accent-400 text-white font-medium rounded-xl transition-all glow-amber-sm"
              >
                <span>Get Started</span>
                <ArrowRight size={16} className="group-hover:translate-x-0.5 transition-transform" />
              </a>
              <a
                href="#architecture"
                className="inline-flex items-center gap-2 px-6 py-3 glass text-slate-300 hover:text-white font-medium rounded-xl transition-colors"
              >
                <span>Learn More</span>
              </a>
            </motion.div>

            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ duration: 0.8, delay: 0.5 }}
              className="flex items-center gap-6 pt-4 text-sm text-slate-500"
            >
              <div className="flex items-center gap-2">
                <Cpu size={14} className="text-accent-400" />
                <span>CEF 148</span>
              </div>
              <div className="flex items-center gap-2">
                <Shield size={14} className="text-accent-400" />
                <span>Local-first AI</span>
              </div>
              <div className="flex items-center gap-2">
                <Sparkles size={14} className="text-accent-400" />
                <span>Liquid Glass</span>
              </div>
            </motion.div>
          </div>

          <motion.div
            initial={{ opacity: 0, scale: 0.95, rotateX: 10 }}
            animate={{ opacity: 1, scale: 1, rotateX: 0 }}
            transition={{ duration: 1, delay: 0.3, ease: 'easeOut' }}
            className="relative perspective-1000"
          >
            <div className="relative rounded-2xl overflow-hidden border border-white/10 shadow-2xl shadow-black/50 glow-amber">
              {/* Browser mockup */}
              <div className="bg-slate-900/90 backdrop-blur-xl">
                {/* Title bar */}
                <div className="flex items-center gap-2 px-4 py-3 border-b border-white/5">
                  <div className="flex gap-1.5">
                    <div className="w-3 h-3 rounded-full bg-red-500/80" />
                    <div className="w-3 h-3 rounded-full bg-yellow-500/80" />
                    <div className="w-3 h-3 rounded-full bg-green-500/80" />
                  </div>
                  <div className="flex-1 mx-4">
                    <div className="max-w-md mx-auto bg-white/5 rounded-lg px-3 py-1.5 text-xs text-slate-500 flex items-center gap-2">
                      <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
                      soul.dev
                      <span className="ml-auto text-slate-600">⌘L</span>
                    </div>
                  </div>
                  <div className="w-16" />
                </div>

                {/* Content area with sidebar */}
                <div className="flex h-[380px]">
                  {/* Vertical tab sidebar */}
                  <div className="w-14 border-r border-white/5 flex flex-col items-center py-3 gap-2 bg-slate-950/50">
                    {[0,1,2,3].map((i) => (
                      <div key={i} className={`w-9 h-9 rounded-lg flex items-center justify-center text-xs ${i === 0 ? 'bg-accent-500/15 text-accent-400 border border-accent-500/20' : 'bg-white/5 text-slate-500'}`}>
                        {i === 0 ? 'S' : i === 1 ? 'G' : i === 2 ? 'X' : '+'}
                      </div>
                    ))}
                    <div className="mt-auto w-9 h-9 rounded-lg flex items-center justify-center text-slate-600">
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 20a8 8 0 1 0 0-16 8 8 0 0 0 0 16Z"/><path d="M12 14a2 2 0 1 0 0-4 2 2 0 0 0 0 4Z"/><path d="M12 2v2"/><path d="M12 20v2"/><path d="m4.93 4.93 1.41 1.41"/><path d="m17.66 17.66 1.41 1.41"/><path d="M2 12h2"/><path d="M20 12h2"/><path d="m6.34 17.66-1.41 1.41"/><path d="m19.07 4.93-1.41 1.41"/></svg>
                    </div>
                  </div>

                  {/* Main content */}
                  <div className="flex-1 p-6 relative overflow-hidden">
                    <div className="space-y-4 max-w-lg">
                      <div className="h-8 w-48 bg-white/5 rounded-lg" />
                      <div className="space-y-2">
                        <div className="h-3 w-full bg-white/[0.03] rounded" />
                        <div className="h-3 w-5/6 bg-white/[0.03] rounded" />
                        <div className="h-3 w-4/6 bg-white/[0.03] rounded" />
                      </div>
                      <div className="grid grid-cols-3 gap-3 pt-2">
                        {[0,1,2].map(i => (
                          <div key={i} className="aspect-video bg-white/[0.04] rounded-lg border border-white/5" />
                        ))}
                      </div>
                    </div>

                    {/* AI Panel overlay */}
                    <div className="absolute bottom-4 right-4 w-64 glass rounded-xl p-3 border border-accent-500/10">
                      <div className="flex items-center gap-2 mb-2">
                        <div className="w-5 h-5 rounded-full bg-accent-500/20 flex items-center justify-center">
                          <Sparkles size={10} className="text-accent-400" />
                        </div>
                        <span className="text-xs font-medium text-slate-300">Soul Assistant</span>
                      </div>
                      <div className="space-y-1.5">
                        <div className="h-2 w-full bg-white/5 rounded" />
                        <div className="h-2 w-3/4 bg-white/5 rounded" />
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Decorative glow */}
            <div className="absolute -inset-4 bg-gradient-to-r from-accent-500/10 via-transparent to-accent-500/10 rounded-3xl blur-2xl -z-10" />
          </motion.div>
        </div>
      </div>
    </section>
  )
}
