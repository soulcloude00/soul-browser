import { useRef } from 'react'
import { motion, useInView } from 'framer-motion'
import { Rocket, Map, CheckCircle2 } from 'lucide-react'

const parts = [
  {
    title: 'Core Architecture',
    items: [
      'Unified Run-Loop Optimization',
      'Apple Silicon Metal Rendering',
      'Liquid Glass Overlays',
      'Custom Window Styling',
      'Multi-Window Coordination',
      'Native Sharesheet Integration',
      'Core Spotlight Indexing',
      'Picture-in-Picture',
      'Haptic Feedback',
      'Keychain Storage',
      'Low Power Mode',
      'Drag & Drop Pipeline',
    ],
    done: 12,
  },
  {
    title: 'Local-First AI',
    items: [
      'Visual LLM Configurator',
      'Reader Mode AI Summary',
      'Clipboard Context Injector',
      'Smart Rewrite Tool',
      'Voice Control & Transcription',
      'Browser Automation Suite',
      'Semantic History Search',
      'AI Ad-Blocker',
      'Offline Translation',
      'AI Form Filler',
      'Contextual Tab Grouping',
      'Developer Helper Panel',
    ],
    done: 12,
  },
  {
    title: 'Performance',
    items: [
      'Heuristic Tab Suspender',
      'Memory Visualizer',
      'Shared V8 Allocator',
      'GC Sweeper',
      'Resource Preloader',
      'Video Decode Accelerator',
      'Process Priority Rebalancer',
      'WebGL Capture Optimization',
      'Battery-Aware Throttling',
      'Parallel Renderer Boot',
    ],
    done: 10,
  },
  {
    title: 'Privacy & Security',
    items: [
      'Declarative Blocklist Engine',
      'Privacy Dashboard',
      'HTTPS-Only Mode',
      'Fingerprint Randomization',
      'Per-Site Permission Manager',
      'Secure DNS Over HTTPS',
      'Cookie Isolation',
      'Content Security Policy Reporter',
    ],
    done: 8,
  },
]

function PartCard({ part, index }: { part: typeof parts[0]; index: number; key?: string }) {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: '-50px' })

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 24 }}
      animate={isInView ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.5, delay: index * 0.1 }}
      className="glass-card p-6 rounded-2xl"
    >
      <div className="flex items-center justify-between mb-3">
        <h3 className="text-[14px] font-semibold text-white/80">{part.title}</h3>
        <span className="text-[11px] text-orange-400/80 bg-orange-500/[0.08] px-2 py-0.5 rounded-full border border-orange-500/[0.1]">
          {part.done}/{part.items.length}
        </span>
      </div>
      <div className="w-full h-[3px] bg-white/[0.03] rounded-full mb-4 overflow-hidden">
        <motion.div
          initial={{ width: 0 }}
          animate={isInView ? { width: `${(part.done / part.items.length) * 100}%` } : {}}
          transition={{ duration: 1, delay: 0.4, ease: [0.22, 1, 0.36, 1] }}
          className="h-full bg-gradient-to-r from-orange-500 to-amber-400 rounded-full"
        />
      </div>
      <ul className="space-y-1.5">
        {part.items.map((item) => (
          <li key={item} className="flex items-center gap-2 text-[12px] text-slate-500">
            <CheckCircle2 size={11} className="text-emerald-500/60 flex-shrink-0" />
            <span>{item}</span>
          </li>
        ))}
      </ul>
    </motion.div>
  )
}

export default function Roadmap() {
  const headerRef = useRef(null)
  const isHeaderInView = useInView(headerRef, { once: true, margin: '-80px' })

  const totalDone = parts.reduce((acc, p) => acc + p.done, 0)
  const totalItems = parts.reduce((acc, p) => acc + p.items.length, 0)

  return (
    <section id="roadmap" className="py-28 md:py-36 relative">
      <div className="max-w-6xl mx-auto px-6 relative z-10">
        <motion.div
          ref={headerRef}
          initial={{ opacity: 0, y: 24 }}
          animate={isHeaderInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full glass text-[11px] text-orange-300/70 mb-6 tracking-wide uppercase font-medium">
            <Map size={10} />
            <span>Roadmap</span>
          </div>
          <h2 className="text-4xl md:text-5xl font-bold tracking-[-0.02em] leading-[1.1] text-white mb-5 text-balance">
            <span className="gradient-text">106 features</span> planned
          </h2>
          <p className="text-base text-slate-500 max-w-xl mx-auto leading-[1.7] mb-10">
            A deeply-crafted roadmap spanning architecture, AI, performance, privacy, and developer tooling.
          </p>

          <div className="inline-flex items-center gap-5 px-7 py-4 rounded-2xl glass-strong border border-white/[0.06]">
            <div className="text-center">
              <div className="text-2xl font-bold text-orange-400/90">{totalDone}</div>
              <div className="text-[11px] text-slate-600 mt-0.5">Shipped</div>
            </div>
            <div className="w-px h-8 bg-white/[0.06]" />
            <div className="text-center">
              <div className="text-2xl font-bold text-white/80">{totalItems}</div>
              <div className="text-[11px] text-slate-600 mt-0.5">Planned</div>
            </div>
            <div className="w-px h-8 bg-white/[0.06]" />
            <div className="text-center">
              <div className="text-2xl font-bold text-emerald-400/80">{Math.round((totalDone / 106) * 100)}%</div>
              <div className="text-[11px] text-slate-600 mt-0.5">Complete</div>
            </div>
          </div>
        </motion.div>

        <div className="grid md:grid-cols-2 gap-3">
          {parts.map((part, i) => (
            <PartCard key={part.title} part={part} index={i} />
          ))}
        </div>

        <motion.div
          initial={{ opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.3 }}
          className="mt-14 text-center"
        >
          <a
            href="https://github.com/soulcloude/mori-browser/blob/main/ROADMAP.md"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2 px-5 py-2.5 text-sm text-slate-400 hover:text-white rounded-xl transition-colors border border-white/[0.05] hover:border-white/10 bg-white/[0.02] active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-white/10"
          >
            <Rocket size={13} />
            <span>View full roadmap on GitHub</span>
          </a>
        </motion.div>
      </div>
    </section>
  )
}
