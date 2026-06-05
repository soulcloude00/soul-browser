import { useRef, useState } from 'react'
import { motion, useInView, AnimatePresence } from 'framer-motion'
import {
  Brain,
  Zap,
  Layout,
  Shield,
  Terminal,
  Gauge,
  Eye,
  Lock,
  ChevronRight,
} from 'lucide-react'

const features = [
  {
    icon: Brain,
    title: 'Local AI',
    short: 'Codex-powered assistant running entirely on your machine.',
    full: 'A built-in Codex assistant with browser automation, page summaries, clipboard analysis, and reader mode - all local, zero cloud. Supports Ollama and LM Studio.',
  },
  {
    icon: Zap,
    title: 'Metal Rendering',
    short: 'Native Apple Silicon Metal for CEF.',
    full: '40% less GPU memory usage, buttery 120Hz ProMotion scrolling, and hardware-accelerated video decode on Apple Silicon Macs.',
  },
  {
    icon: Layout,
    title: 'Vertical Tabs',
    short: 'Right-hand sidebar with tree hierarchies.',
    full: 'Workspace audio mixing, focus mode, tree hierarchies, and a command palette for instant tab search. Always visible, never cluttered.',
  },
  {
    icon: Shield,
    title: 'Privacy First',
    short: 'Declarative blocklist, Keychain, tracker blocking.',
    full: 'Real-time privacy dashboard, native Keychain integration, per-site permissions, and a declarative blocklist engine that blocks before the request fires.',
  },
  {
    icon: Terminal,
    title: 'Dev Tools',
    short: 'Terminal sidebar, HTTP inspector, live console.',
    full: 'Integrated terminal, HTTP request/response inspector, responsive layout canvas, JSON formatter, color picker, local SSL certificate manager, and web asset downloader.',
  },
  {
    icon: Gauge,
    title: 'Performance',
    short: 'Tab suspension, shared V8, hardware decode.',
    full: 'Heuristic tab suspension, shared V8 context allocator, GC sweeper, resource preloader, and battery-aware throttling when unplugged.',
  },
  {
    icon: Eye,
    title: 'Semantic History',
    short: 'Embedding-based natural language search.',
    full: 'Local SQLite vector store with embedding-based search. Find that Rust article from Tuesday by typing exactly that. No cloud, no indexing services.',
  },
  {
    icon: Lock,
    title: 'Native Security',
    short: 'Keychain, LAN sync, SSL manager.',
    full: 'Native Keychain Services, LAN sync via Bonjour, local SSL certificate manager, crash recovery, and cookie isolation by default.',
  },
]

function FeatureCard({ feature, index }: { feature: typeof features[0]; index: number; key?: string }) {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: '-50px' })
  const [expanded, setExpanded] = useState(false)

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 24 }}
      animate={isInView ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.5, delay: index * 0.05 }}
      className="group relative"
    >
      <button
        onClick={() => setExpanded(!expanded)}
        className="w-full h-full text-left relative p-5 rounded-2xl panel overflow-hidden hover:-translate-y-0.5 active:scale-[0.99] focus:outline-none focus:ring-2 focus:ring-white/10"
      >
        <div className="relative">
          <div className="flex items-start justify-between mb-4">
            <div className="w-10 h-10 rounded-xl bg-orange-500/[0.07] border border-orange-500/15 flex items-center justify-center transition-colors duration-300 group-hover:bg-orange-500/[0.12]">
              <feature.icon size={18} strokeWidth={1.75} className="text-orange-400" />
            </div>
            <span className="font-mono text-[10px] text-slate-700 tabular-nums">{String(index + 1).padStart(2, '0')}</span>
          </div>
          <h3 className="font-display text-[15px] font-medium text-white/90 mb-1.5">{feature.title}</h3>
          <p className="text-[12.5px] text-slate-500 leading-[1.55]">{feature.short}</p>

          <AnimatePresence>
            {expanded && (
              <motion.div
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: 'auto', opacity: 1 }}
                exit={{ height: 0, opacity: 0 }}
                transition={{ duration: 0.3, ease: [0.22, 1, 0.36, 1] }}
                className="overflow-hidden"
              >
                <div className="pt-3 mt-3 border-t border-white/[0.06]">
                  <p className="text-[12.5px] text-slate-400 leading-[1.65]">{feature.full}</p>
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          <div className="mt-3 flex items-center gap-1 text-[11px] text-slate-600 group-hover:text-orange-400/80 transition-colors">
            <span>{expanded ? 'Less' : 'Details'}</span>
            <ChevronRight size={12} className={`transition-transform duration-300 ${expanded ? 'rotate-90' : 'group-hover:translate-x-0.5'}`} />
          </div>
        </div>
      </button>
    </motion.div>
  )
}

export default function Features() {
  const headerRef = useRef(null)
  const isHeaderInView = useInView(headerRef, { once: true, margin: '-80px' })

  return (
    <section id="features" className="py-24 md:py-32">
      <div className="max-w-5xl mx-auto px-6">
        <motion.div
          ref={headerRef}
          initial={{ opacity: 0, y: 24 }}
          animate={isHeaderInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="max-w-2xl mb-14"
        >
          <h2 className="font-display font-semibold text-4xl md:text-5xl tracking-[-0.03em] leading-[1.02] text-white mb-5 text-balance">
            Built for the way <span className="text-orange-400">you</span> work
          </h2>
          <p className="text-base text-slate-400 max-w-md leading-[1.6]">
            Eight native systems, each crafted for macOS power users. Tap a card to expand.
          </p>
        </motion.div>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-4 items-stretch">
          {features.map((feature, i) => (
            <FeatureCard key={feature.title} feature={feature} index={i} />
          ))}
        </div>
      </div>
    </section>
  )
}
