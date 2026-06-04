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
    title: 'Local AI',
    description: 'Codex-powered assistant that runs entirely on your machine. Browser automation, page summaries, and clipboard analysis — zero cloud.',
    size: 'large',
  },
  {
    icon: Zap,
    title: 'Metal Rendering',
    description: 'Native Apple Silicon Metal for CEF. 40% less GPU memory, 120Hz ProMotion.',
    size: 'small',
  },
  {
    icon: Layout,
    title: 'Vertical Tabs',
    description: 'Right-hand vertical sidebar with tree hierarchies, workspace audio mixing, and focus mode.',
    size: 'small',
  },
  {
    icon: Shield,
    title: 'Privacy First',
    description: 'Declarative blocklist, real-time dashboard, native Keychain, and tracker blocking by default.',
    size: 'small',
  },
  {
    icon: Terminal,
    title: 'Dev Tools',
    description: 'Terminal sidebar, HTTP inspector, responsive canvas, JSON formatter, color picker, live console.',
    size: 'large',
  },
  {
    icon: Gauge,
    title: 'Performance',
    description: 'Heuristic tab suspension, shared V8 allocator, hardware decode, battery-aware throttling.',
    size: 'small',
  },
  {
    icon: Eye,
    title: 'Semantic History',
    description: 'Embedding-based search. "That Rust article from Tuesday" — in plain English.',
    size: 'small',
  },
  {
    icon: Lock,
    title: 'Native Security',
    description: 'Keychain Services, LAN sync via Bonjour, SSL manager, crash recovery.',
    size: 'small',
  },
  {
    icon: Command,
    title: 'Command Palette',
    description: 'Floating quick commands, tab search console, keyboard-first everything.',
    size: 'small',
  },
]

function FeatureCard({ feature, index }: { feature: typeof features[0]; index: number; key?: string }) {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: '-60px' })

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 30 }}
      animate={isInView ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.5, delay: index * 0.05 }}
      className={`group relative ${feature.size === 'large' ? 'md:col-span-2' : ''}`}
    >
      <div className="relative h-full p-6 rounded-2xl glass-card overflow-hidden">
        {/* Subtle gradient on hover */}
        <div className="absolute inset-0 bg-gradient-to-br from-orange-500/[0.03] to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-700" />

        <div className="relative">
          <div className="w-9 h-9 rounded-lg bg-gradient-to-br from-white/[0.06] to-white/[0.02] border border-white/[0.06] flex items-center justify-center mb-4 group-hover:border-orange-500/20 transition-colors duration-500">
            <feature.icon size={16} strokeWidth={1.5} className="text-orange-400/70 group-hover:text-orange-400 transition-colors duration-500" />
          </div>
          <h3 className="text-[15px] font-semibold text-white/90 mb-1.5">{feature.title}</h3>
          <p className="text-[13px] text-slate-500 leading-[1.6] group-hover:text-slate-400 transition-colors duration-500">{feature.description}</p>
        </div>
      </div>
    </motion.div>
  )
}

export default function Features() {
  const headerRef = useRef(null)
  const isHeaderInView = useInView(headerRef, { once: true, margin: '-80px' })

  return (
    <section id="features" className="py-28 md:py-36">
      <div className="max-w-6xl mx-auto px-6">
        <motion.div
          ref={headerRef}
          initial={{ opacity: 0, y: 24 }}
          animate={isHeaderInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-20"
        >
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full glass text-[11px] text-orange-300/70 mb-6 tracking-wide uppercase font-medium">
            <Sparkles size={10} />
            <span>Features</span>
          </div>
          <h2 className="text-[2.5rem] md:text-[3rem] font-bold tracking-[-0.02em] leading-[1.1] text-white mb-5">
            Built for the way <span className="gradient-text">you</span> work
          </h2>
          <p className="text-[15px] text-slate-500 max-w-xl mx-auto leading-[1.7]">
            Every feature crafted for macOS power users who refuse to compromise on privacy, speed, or craft.
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
