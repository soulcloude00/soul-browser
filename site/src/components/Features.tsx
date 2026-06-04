import { useRef } from 'react'
import { motion, useInView } from 'framer-motion'
import {
  Brain,
  Zap,
  Layout,
  Shield,
  Terminal,
  Gauge,
  Eye,
  Lock,
  Command,
  Sparkles,
} from 'lucide-react'

const features = [
  {
    icon: Brain,
    title: 'Local AI Assistant',
    description: 'Built-in Codex-powered assistant with browser automation. Runs entirely on your machine with broad filesystem access.',
    color: 'from-amber-500/20 to-orange-500/20',
    iconColor: 'text-amber-400',
  },
  {
    icon: Zap,
    title: 'Metal Rendering',
    description: 'Native Apple Silicon Metal rendering for CEF. 40% less GPU memory, buttery 120Hz ProMotion scrolling.',
    color: 'from-orange-500/20 to-red-500/20',
    iconColor: 'text-orange-400',
  },
  {
    icon: Layout,
    title: 'Vertical Tabs',
    description: 'Right-hand vertical tab sidebar by default. Tree hierarchies, workspace audio mixing, and focus mode.',
    color: 'from-emerald-500/20 to-teal-500/20',
    iconColor: 'text-emerald-400',
  },
  {
    icon: Shield,
    title: 'Privacy First',
    description: 'Declarative blocklist engine, real-time privacy dashboard, native Keychain storage, and tracker blocking.',
    color: 'from-cyan-500/20 to-blue-500/20',
    iconColor: 'text-cyan-400',
  },
  {
    icon: Terminal,
    title: 'Developer Tools',
    description: 'Integrated terminal sidebar, HTTP inspector, responsive canvas, JSON formatter, color picker, and mini console.',
    color: 'from-violet-500/20 to-purple-500/20',
    iconColor: 'text-violet-400',
  },
  {
    icon: Gauge,
    title: 'Performance',
    description: 'Heuristic tab suspension, shared V8 context allocator, hardware video decode, and battery-aware throttling.',
    color: 'from-pink-500/20 to-rose-500/20',
    iconColor: 'text-pink-400',
  },
  {
    icon: Eye,
    title: 'Semantic History',
    description: 'Local embedding-based semantic search. Find that page about Rust optimizations from last Tuesday, in plain English.',
    color: 'from-sky-500/20 to-indigo-500/20',
    iconColor: 'text-sky-400',
  },
  {
    icon: Lock,
    title: 'Native Security',
    description: 'Native Keychain Services integration, LAN sync via Bonjour, local SSL certificate manager, and crash recovery.',
    color: 'from-lime-500/20 to-green-500/20',
    iconColor: 'text-lime-400',
  },
  {
    icon: Command,
    title: 'Command Palette',
    description: 'Floating quick commands, tab search console, and keyboard-first navigation. Every action is a keystroke away.',
    color: 'from-yellow-500/20 to-amber-500/20',
    iconColor: 'text-yellow-400',
  },
]

function FeatureCard({ feature, index }: { feature: typeof features[0]; index: number; key?: string }) {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: '-80px' })

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 40 }}
      animate={isInView ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.5, delay: index * 0.06 }}
      className="group relative"
    >
      <div className="relative h-full p-6 rounded-2xl glass hover:bg-white/[0.05] transition-all duration-500 border border-white/[0.06] hover:border-white/10">
        <div className={`absolute inset-0 rounded-2xl bg-gradient-to-br ${feature.color} opacity-0 group-hover:opacity-100 transition-opacity duration-500`} />
        <div className="relative">
          <div className={`w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center mb-4 ${feature.iconColor}`}>
            <feature.icon size={20} strokeWidth={1.5} />
          </div>
          <h3 className="text-base font-semibold text-slate-100 mb-2">{feature.title}</h3>
          <p className="text-sm text-slate-400 leading-relaxed">{feature.description}</p>
        </div>
      </div>
    </motion.div>
  )
}

export default function Features() {
  const headerRef = useRef(null)
  const isHeaderInView = useInView(headerRef, { once: true, margin: '-100px' })

  return (
    <section id="features" className="py-24 md:py-32">
      <div className="max-w-7xl mx-auto px-6">
        <motion.div
          ref={headerRef}
          initial={{ opacity: 0, y: 30 }}
          animate={isHeaderInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full glass text-xs text-accent-300 mb-6">
            <Sparkles size={12} />
            <span>106 features planned, many already shipped</span>
          </div>
          <h2 className="text-4xl md:text-5xl font-bold tracking-tight mb-4">
            Everything you need, <span className="gradient-text">nothing you don&apos;t</span>
          </h2>
          <p className="text-lg text-slate-400 max-w-2xl mx-auto">
            Soul is built from the ground up for macOS power users who want a browser
            that respects their privacy, leverages local AI, and feels native.
          </p>
        </motion.div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
          {features.map((feature, i) => (
            <FeatureCard key={feature.title} feature={feature} index={i} />
          ))}
        </div>
      </div>
    </section>
  )
}
