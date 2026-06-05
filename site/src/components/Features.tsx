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
  Sparkles,
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
        className="w-full text-left relative p-5 rounded-2xl glass-card overflow-hidden active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-white/10"
      >
        <div className="absolute inset-0 bg-gradient-to-br from-orange-500/[0.02] to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />

        <div className="relative">
          <div className="flex items-start justify-between mb-3">
            <div className="w-9 h-9 rounded-lg bg-gradient-to-br from-white/[0.06] to-white/[0.02] border border-white/[0.06] flex items-center justify-center group-hover:border-orange-500/20 transition-colors duration-500">
              <feature.icon size={16} strokeWidth={1.5} className="text-orange-400/60 group-hover:text-orange-400 transition-colors duration-500" />
            </div>
            <ChevronRight size={14} className={`text-slate-700 transition-transform duration-300 ${expanded ? 'rotate-90' : 'group-hover:translate-x-0.5'}`} />
          </div>
          <h3 className="text-[14px] font-semibold text-white/80 mb-1">{feature.title}</h3>
          <p className="text-[12px] text-slate-500 leading-[1.6]">{feature.short}</p>

          <AnimatePresence>
            {expanded && (
              <motion.div
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: 'auto', opacity: 1 }}
                exit={{ height: 0, opacity: 0 }}
                transition={{ duration: 0.3, ease: [0.22, 1, 0.36, 1] }}
                className="overflow-hidden"
              >
                <div className="pt-3 mt-3 border-t border-white/[0.04]">
                  <p className="text-[12px] text-slate-400 leading-[1.7]">{feature.full}</p>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
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
          className="text-center mb-16"
        >
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full glass text-[11px] text-orange-300/70 mb-6 tracking-wide uppercase font-medium">
            <Sparkles size={10} />
            <span>Features</span>
          </div>
          <h2 className="text-4xl md:text-5xl font-bold tracking-[-0.02em] leading-[1.1] text-white mb-4 text-balance">
            Built for the way <span className="gradient-text">you</span> work
          </h2>
          <p className="text-sm text-slate-500 max-w-lg mx-auto leading-[1.7]">
            Click any card to explore. Every feature crafted for macOS power users.
          </p>
        </motion.div>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-3">
          {features.map((feature, i) => (
            <FeatureCard key={feature.title} feature={feature} index={i} />
          ))}
        </div>
      </div>
    </section>
  )
}
