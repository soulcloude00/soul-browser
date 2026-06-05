import { useRef } from 'react'
import { motion, useInView } from 'framer-motion'
import {
  Brain,
  Zap,
  Layout,
  Shield,
  Fingerprint,
  HardDrive
} from 'lucide-react'

const features = [
  {
    icon: Zap,
    title: 'Apple Silicon Native',
    short: 'SwiftUI & AppKit native shell drawing directly to Metal.',
    full: 'By embedding CEF rather than packing Electron, Soul achieves 40% less GPU memory consumption, butter-smooth 120Hz ProMotion scrolling, and hardware-accelerated video decode on Apple Silicon. True native macOS window blending.',
    span: 'md:col-span-2 md:row-span-2',
    visual: (
      <div className="absolute inset-0 right-0 top-1/2 left-1/3 bg-gradient-to-br from-orange-500/10 to-transparent rounded-tl-3xl border-t border-l border-orange-500/20" />
    )
  },
  {
    icon: Brain,
    title: 'Local-First AI',
    short: 'On-device LLMs for 100% private, offline assistance.',
    full: 'A built-in Codex assistant with browser automation, smart page summaries, clipboard analysis, and reasoning controls. Works offline via Ollama or LM Studio. Zero telemetry leaves your machine.',
    span: 'md:col-span-2 md:row-span-1',
  },
  {
    icon: Shield,
    title: 'Uncompromising Privacy',
    short: 'Request-level ad and tracker blocking.',
    full: 'Our declarative blocking engine intercepts and drops analytics, tracking beacons, and ads before the web request is even fired. Upgrades pages load speed by up to 3x.',
    span: 'md:col-span-1 md:row-span-1',
  },
  {
    icon: Layout,
    title: 'Spatial Right-Hand Tabs',
    short: 'Right-hand sidebar with native workspace isolation.',
    full: 'Keep your focus where it belongs. Features space-based tab groups, audio mixing, tree hierarchies, focus mode, and a global Command Palette (⌘K).',
    span: 'md:col-span-1 md:row-span-1',
  },
  {
    icon: Fingerprint,
    title: 'Zero Fingerprinting',
    short: 'Anti-fingerprinting via Canvas and WebGL noise.',
    full: 'Protects your identity online by spoofing your browser plugins list, rounding screen dimension queries, and injecting Canvas noise into rendering buffers.',
    span: 'md:col-span-2 md:row-span-1',
  },
  {
    icon: HardDrive,
    title: 'Semantic SQLite History',
    short: 'Vector-based natural language history search.',
    full: 'Find that article from last week by searching context: "article about Rust MIR optimizer with the blue diagram". Fully offline.',
    span: 'md:col-span-2 md:row-span-1',
  }
]

function FeatureCard({ feature, index }: { feature: typeof features[0]; index: number }) {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: '-50px' })

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 30 }}
      animate={isInView ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.6, delay: index * 0.1, ease: [0.22, 1, 0.36, 1] }}
      className={`group relative p-6 md:p-8 rounded-3xl panel overflow-hidden hover:-translate-y-1 transition-all duration-500 ${feature.span}`}
    >
      {feature.visual}
      <div className="relative z-10 h-full flex flex-col">
        <div className="w-12 h-12 rounded-xl bg-orange-600/10 border border-orange-600/20 flex items-center justify-center mb-6 transition-colors duration-300 group-hover:bg-orange-600/20">
          <feature.icon size={22} strokeWidth={1.5} className="text-orange-600" />
        </div>
        <h3 className="font-display text-xl md:text-2xl font-semibold text-zinc-900 dark:text-zinc-100 mb-3 transition-colors">{feature.title}</h3>
        <p className="text-sm font-medium text-zinc-700 dark:text-zinc-300 mb-3 transition-colors">{feature.short}</p>
        <p className="text-[13px] text-zinc-500 dark:text-zinc-450 leading-relaxed transition-colors mt-auto">{feature.full}</p>
      </div>
    </motion.div>
  )
}

export default function Features() {
  const headerRef = useRef(null)
  const isHeaderInView = useInView(headerRef, { once: true, margin: '-80px' })

  return (
    <section id="features" className="py-24 md:py-32 bg-transparent border-t border-zinc-900/10 dark:border-white/10 relative overflow-hidden">
      <div className="max-w-6xl mx-auto px-6">
        <motion.div
          ref={headerRef}
          initial={{ opacity: 0, y: 24 }}
          animate={isHeaderInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
          className="max-w-2xl mb-16"
        >
          <h2 className="font-display font-semibold text-4xl md:text-5xl tracking-[-0.03em] leading-[1.02] text-[#14130f] dark:text-zinc-100 mb-5 text-balance transition-colors">
            A totally new <span className="text-orange-600">architecture</span>
          </h2>
          <p className="text-lg text-zinc-650 dark:text-zinc-400 max-w-md leading-relaxed transition-colors">
            Soul isn't an Electron wrapper. It's a deep integration of CEF into native macOS AppKit.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 auto-rows-[minmax(200px,auto)]">
          {features.map((feature, i) => (
            <FeatureCard key={feature.title} feature={feature} index={i} />
          ))}
        </div>
      </div>
    </section>
  )
}
