import { useRef, MouseEvent } from 'react'
import { motion, useInView } from 'framer-motion'
import { Zap, Brain, Shield, PanelRight, Fingerprint, Database, LucideIcon } from 'lucide-react'

const ease = [0.22, 1, 0.36, 1] as const

type Feature = {
  icon: LucideIcon
  index: string
  title: string
  body: string
  span: string
}

const features: Feature[] = [
  {
    icon: Zap,
    index: '01',
    title: 'Apple Silicon, all the way down',
    body: 'No Electron in sight. A SwiftUI + AppKit shell draws straight to Metal, embedding CEF for ~40% less GPU memory, hardware video decode and butter-smooth 120Hz ProMotion scrolling.',
    span: 'md:col-span-2',
  },
  {
    icon: Brain,
    index: '02',
    title: 'AI that stays home',
    body: 'A built-in assistant for page summaries, automation and reasoning — running on-device via Ollama or LM Studio. Works offline. Nothing phones home.',
    span: 'md:col-span-1',
  },
  {
    icon: Shield,
    index: '03',
    title: 'Blocking before the wire',
    body: 'A declarative engine drops ads, beacons and trackers before the request even fires. Pages load up to 3× faster.',
    span: 'md:col-span-1',
  },
  {
    icon: PanelRight,
    index: '04',
    title: 'Spatial right-hand tabs',
    body: 'Vertical tabs in a translucent sidebar, with space-based groups, tree hierarchies, focus mode and a global ⌘K palette.',
    span: 'md:col-span-1',
  },
  {
    icon: Fingerprint,
    index: '05',
    title: 'Zero fingerprinting',
    body: 'Canvas noise, WebGL spoofing, rounded screen metrics. Your identity blurs into the crowd.',
    span: 'md:col-span-1',
  },
  {
    icon: Database,
    index: '06',
    title: 'History that understands you',
    body: 'Semantic SQLite history with vector search. Find "that Rust article with the blue diagram" — in plain language, fully offline.',
    span: 'md:col-span-2',
  },
]

function Card({ feature, i }: { feature: Feature; i: number }) {
  const ref = useRef<HTMLDivElement>(null)
  const inView = useInView(ref, { once: true, margin: '-60px' })

  const onMove = (e: MouseEvent<HTMLDivElement>) => {
    const el = ref.current
    if (!el) return
    const r = el.getBoundingClientRect()
    el.style.setProperty('--mx', `${e.clientX - r.left}px`)
    el.style.setProperty('--my', `${e.clientY - r.top}px`)
  }

  return (
    <motion.div
      ref={ref}
      onMouseMove={onMove}
      initial={{ opacity: 0, y: 40 }}
      animate={inView ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.7, delay: (i % 3) * 0.08, ease }}
      className={`spotlight group relative p-8 md:p-10 rounded-2xl border hairline bg-coal/60 hover:border-ember/30 transition-colors duration-500 ${feature.span}`}
    >
      <div className="flex items-start justify-between mb-10">
        <feature.icon size={22} strokeWidth={1.5} className="text-ember" />
        <span className="font-mono text-[11px] text-dim tracking-[0.2em]">{feature.index}</span>
      </div>
      <h3 className="font-display text-xl md:text-2xl font-medium tracking-tight mb-3">
        {feature.title}
      </h3>
      <p className="text-[14px] text-ash leading-relaxed max-w-md">{feature.body}</p>
    </motion.div>
  )
}

export default function Features() {
  const headRef = useRef(null)
  const headIn = useInView(headRef, { once: true, margin: '-80px' })

  return (
    <section id="features" className="py-28 md:py-40">
      <div className="max-w-7xl mx-auto px-6 lg:px-10">
        <motion.div
          ref={headRef}
          initial={{ opacity: 0, y: 32 }}
          animate={headIn ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8, ease }}
          className="mb-16 md:mb-20 flex flex-col md:flex-row md:items-end md:justify-between gap-8"
        >
          <div>
            <p className="eyebrow mb-6">/ what makes it soul</p>
            <h2 className="font-display font-medium tracking-tightest leading-[0.95] text-4xl md:text-6xl text-balance max-w-2xl">
              Built like an instrument,{' '}
              <em className="font-serif italic text-ember">not an app</em>
            </h2>
          </div>
          <p className="text-ash text-[15px] leading-relaxed max-w-sm md:text-right">
            Every layer — engine, chrome, AI — engineered native for macOS.
            Nothing borrowed, nothing bloated.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {features.map((f, i) => (
            <Card key={f.index} feature={f} i={i} />
          ))}
        </div>
      </div>
    </section>
  )
}
