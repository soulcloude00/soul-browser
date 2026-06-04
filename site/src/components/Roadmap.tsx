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
  const isInView = useInView(ref, { once: true, margin: '-60px' })

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 30 }}
      animate={isInView ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.5, delay: index * 0.1 }}
      className="p-6 rounded-2xl glass border border-white/[0.06] hover:border-white/10 transition-colors"
    >
      <div className="flex items-center justify-between mb-4">
        <h3 className="font-semibold text-slate-200">{part.title}</h3>
        <span className="text-xs text-accent-400 bg-accent-500/10 px-2 py-1 rounded-full">
          {part.done}/{part.items.length} done
        </span>
      </div>
      <div className="w-full h-1.5 bg-white/5 rounded-full mb-4 overflow-hidden">
        <motion.div
          initial={{ width: 0 }}
          animate={isInView ? { width: `${(part.done / part.items.length) * 100}%` } : {}}
          transition={{ duration: 0.8, delay: 0.3 }}
          className="h-full bg-gradient-to-r from-accent-500 to-amber-400 rounded-full"
        />
      </div>
      <ul className="space-y-2">
        {part.items.map((item) => (
          <li key={item} className="flex items-center gap-2.5 text-sm text-slate-400">
            <CheckCircle2 size={13} className="text-emerald-500/80 flex-shrink-0" />
            <span>{item}</span>
          </li>
        ))}
      </ul>
    </motion.div>
  )
}

export default function Roadmap() {
  const headerRef = useRef(null)
  const isHeaderInView = useInView(headerRef, { once: true, margin: '-100px' })

  const totalDone = parts.reduce((acc, p) => acc + p.done, 0)
  const totalItems = parts.reduce((acc, p) => acc + p.items.length, 0)

  return (
    <section id="roadmap" className="py-24 md:py-32 relative">
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_60%_50%_at_50%_60%,rgba(254,128,16,0.04),transparent)]" />

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        <motion.div
          ref={headerRef}
          initial={{ opacity: 0, y: 30 }}
          animate={isHeaderInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full glass text-xs text-accent-300 mb-6">
            <Map size={12} />
            <span>Progress</span>
          </div>
          <h2 className="text-4xl md:text-5xl font-bold tracking-tight mb-4">
            <span className="gradient-text">106 features</span> planned
          </h2>
          <p className="text-lg text-slate-400 max-w-2xl mx-auto mb-8">
            A deeply-crafted roadmap spanning architecture, AI, performance, privacy,
            developer tooling, and session management.
          </p>

          <div className="inline-flex items-center gap-4 px-6 py-3 rounded-2xl glass border border-accent-500/10">
            <div className="text-center">
              <div className="text-2xl font-bold text-accent-400">{totalDone}</div>
              <div className="text-xs text-slate-500">Shipped</div>
            </div>
            <div className="w-px h-8 bg-white/10" />
            <div className="text-center">
              <div className="text-2xl font-bold text-slate-200">{totalItems}</div>
              <div className="text-xs text-slate-500">In Roadmap</div>
            </div>
            <div className="w-px h-8 bg-white/10" />
            <div className="text-center">
              <div className="text-2xl font-bold text-emerald-400">
                {Math.round((totalDone / 106) * 100)}%
              </div>
              <div className="text-xs text-slate-500">Complete</div>
            </div>
          </div>
        </motion.div>

        <div className="grid md:grid-cols-2 gap-4">
          {parts.map((part, i) => (
            <PartCard key={part.title} part={part} index={i} />
          ))}
        </div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="mt-16 text-center"
        >
          <a
            href="https://github.com/soulcloude/mori-browser/blob/main/ROADMAP.md"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2 px-6 py-3 glass text-slate-300 hover:text-white rounded-xl transition-colors border border-white/10 hover:border-white/20"
          >
            <Rocket size={16} />
            <span>View full roadmap on GitHub</span>
          </a>
        </motion.div>
      </div>
    </section>
  )
}
