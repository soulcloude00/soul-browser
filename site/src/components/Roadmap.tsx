import { useRef } from 'react'
import { motion, useInView } from 'framer-motion'
import { Rocket, CheckCircle2 } from 'lucide-react'

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
      className="panel p-6 rounded-2xl"
    >
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-sm font-semibold text-zinc-900">{part.title}</h3>
        <span className="text-[11px] font-mono tabular-nums text-orange-700 bg-orange-600/10 px-2 py-0.5 rounded-md border border-orange-600/20">
          {part.done}/{part.items.length}
        </span>
      </div>
      <ul className="grid grid-cols-1 sm:grid-cols-2 gap-x-4 gap-y-1.5">
        {part.items.map((item) => (
          <li key={item} className="flex items-center gap-2 text-xs text-zinc-600">
            <CheckCircle2 size={11} className="text-orange-600/70 flex-shrink-0" />
            <span className="truncate">{item}</span>
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
          <h2 className="font-display font-semibold text-4xl md:text-5xl tracking-[-0.03em] leading-[1.02] text-[#14130f] mb-5 text-balance">
            <span className="text-orange-600 tabular-nums">106</span> features planned
          </h2>
          <p className="text-base text-zinc-600 max-w-xl mx-auto leading-[1.6] mb-10">
            A roadmap spanning architecture, AI, performance, privacy, and developer tooling.
          </p>

          <div className="inline-flex items-center gap-5 px-7 py-4 rounded-2xl panel">
            <div className="text-center">
              <div className="text-2xl font-bold text-orange-600 tabular-nums">{totalDone}</div>
              <div className="text-[11px] text-zinc-500 mt-0.5">Shipped</div>
            </div>
            <div className="w-px h-8 bg-zinc-900/10" />
            <div className="text-center">
              <div className="text-2xl font-bold text-zinc-900 tabular-nums">106</div>
              <div className="text-[11px] text-zinc-500 mt-0.5">Planned</div>
            </div>
            <div className="w-px h-8 bg-zinc-900/10" />
            <div className="text-center">
              <div className="text-2xl font-bold text-orange-600 tabular-nums">{Math.round((totalDone / 106) * 100)}%</div>
              <div className="text-[11px] text-zinc-500 mt-0.5">Complete</div>
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
            className="inline-flex items-center gap-2 px-5 py-2.5 text-sm text-zinc-700 hover:text-[#14130f] rounded-xl transition-colors border border-zinc-900/15 hover:border-zinc-900/30 bg-white/40 active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-zinc-900/15"
          >
            <Rocket size={13} />
            <span>View full roadmap on GitHub</span>
          </a>
        </motion.div>
      </div>
    </section>
  )
}
