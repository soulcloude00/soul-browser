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
    title: 'Local AI Assistant',
    short: 'On-device LLMs for 100% private, offline assistance.',
    full: 'A built-in Codex assistant with browser automation, smart page summaries, clipboard analysis, and reasoning controls. Works offline via Ollama or LM Studio. Zero telemetry leaves your machine.',
  },
  {
    icon: Zap,
    title: 'Metal Rendering',
    short: 'SwiftUI & AppKit native shell drawing directly to Metal.',
    full: 'By embedding CEF rather than packing Electron, Soul achieves 40% less GPU memory consumption, butter-smooth 120Hz ProMotion scrolling, and hardware-accelerated video decode on Apple Silicon.',
  },
  {
    icon: Layout,
    title: 'Right-Hand Tabs',
    short: 'Right-hand sidebar with native workspace isolation.',
    full: 'Keep your focus where it belongs. Features space-based tab groups, audio mixing, tree hierarchies, focus mode, and a global Command Palette (⌘K) to jump across sessions instantly.',
  },
  {
    icon: Shield,
    title: 'Privacy Blocklist',
    short: 'Request-level ad and tracker blocking.',
    full: 'Our declarative blocking engine intercepts and drops analytics, tracking beacons, and ads before the web request is even fired. Upgrades pages load speed by up to 3x.',
  },
  {
    icon: Terminal,
    title: 'Cookie & Storage Editor',
    short: 'Inspect and edit cookies and LocalStorage directly.',
    full: 'A dedicated 380pt native side panel to quickly view, filter search, edit, or delete cookies, localStorage, and sessionStorage. No need to toggle full DevTools overlays for basic tweaks.',
  },
  {
    icon: Lock,
    title: 'Fingerprint Protection',
    short: 'Anti-fingerprinting via Canvas and WebGL noise.',
    full: 'Protects your identity online by spoofing your browser plugins list, rounding screen dimension queries, spoofing WebGL vendor as Apple GPU, and injecting Canvas noise into rendering buffers.',
  },
  {
    icon: Eye,
    title: 'Semantic History',
    short: 'Embedding-based natural language history search.',
    full: 'A local SQLite vector store parses your reading history. Find that article from last week by searching context: "article about Rust MIR optimizer with the blue diagram". Offline and private.',
  },
  {
    icon: Gauge,
    title: 'HTTPS-Only & Session Rescue',
    short: 'Strict HTTPS upgrading and crash recovery.',
    full: 'Automatically forces insecure HTTP connections onto HTTPS. In the event of a system crash, a native session restore modal prompts you to restart fresh or resume your exact tab stack.',
  },
]

function FeatureCard({ feature, index }: { feature: typeof features[0]; index: number }) {
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
        className="w-full h-full text-left relative p-5 rounded-2xl panel overflow-hidden hover:-translate-y-0.5 active:scale-[0.99] focus:outline-none focus:ring-2 focus:ring-orange-655/20"
      >
        <div className="relative">
          <div className="flex items-start justify-between mb-4">
            <div className="w-10 h-10 rounded-xl bg-orange-600/10 border border-orange-600/20 flex items-center justify-center transition-colors duration-300 group-hover:bg-orange-600/15">
              <feature.icon size={18} strokeWidth={1.75} className="text-orange-600" />
            </div>
            <span className="font-mono text-[10px] text-zinc-400 dark:text-zinc-500 tabular-nums">{String(index + 1).padStart(2, '0')}</span>
          </div>
          <h3 className="font-display text-[15px] font-semibold text-zinc-900 dark:text-zinc-100 mb-1.5 transition-colors">{feature.title}</h3>
          <p className="text-[12.5px] text-zinc-500 dark:text-zinc-400 leading-[1.55] transition-colors">{feature.short}</p>

          <AnimatePresence>
            {expanded && (
              <motion.div
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: 'auto', opacity: 1 }}
                exit={{ height: 0, opacity: 0 }}
                transition={{ duration: 0.3, ease: [0.22, 1, 0.36, 1] }}
                className="overflow-hidden"
              >
                <div className="pt-3 mt-3 border-t border-zinc-900/10 dark:border-white/10 transition-colors">
                  <p className="text-[12.5px] text-zinc-650 dark:text-zinc-450 leading-[1.65]">{feature.full}</p>
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          <div className="mt-3 flex items-center gap-1 text-[11px] text-zinc-500 dark:text-zinc-400 group-hover:text-orange-600 transition-colors">
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
    <section id="features" className="py-24 md:py-32 bg-transparent border-t border-zinc-900/10 dark:border-white/10">
      <div className="max-w-5xl mx-auto px-6">
        <motion.div
          ref={headerRef}
          initial={{ opacity: 0, y: 24 }}
          animate={isHeaderInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="max-w-2xl mb-14"
        >
          <h2 className="font-display font-semibold text-4xl md:text-5xl tracking-[-0.03em] leading-[1.02] text-[#14130f] dark:text-zinc-100 mb-5 text-balance transition-colors">
            Built for the way <span className="text-orange-600">you</span> work
          </h2>
          <p className="text-base text-zinc-655 dark:text-zinc-400 max-w-md leading-[1.6] transition-colors">
            Eight native subsystems, each crafted for macOS power users. Tap a card to expand details.
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
