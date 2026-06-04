import { useRef } from 'react'
import { motion, useInView } from 'framer-motion'
import { Layers, ArrowRightLeft, Monitor, Sparkles } from 'lucide-react'

const layers = [
  {
    title: 'SwiftUI Chrome',
    subtitle: 'RootView · Toolbar · Sidebar · AIPanel · Settings',
    icon: Layers,
    accent: 'from-violet-500/10 to-violet-600/5',
    border: 'border-violet-500/10',
    text: 'text-violet-300/80',
    dot: 'bg-violet-400',
  },
  {
    title: 'ObjC Bridge',
    subtitle: 'SoulBrowserView header — pure ObjC, Swift-facing',
    icon: ArrowRightLeft,
    accent: 'from-orange-500/10 to-orange-600/5',
    border: 'border-orange-500/10',
    text: 'text-orange-300/80',
    dot: 'bg-orange-400',
  },
  {
    title: 'CEF Engine',
    subtitle: 'Chromium 148 · CEF 148 · MetalRenderHandler',
    icon: Monitor,
    accent: 'from-emerald-500/10 to-emerald-600/5',
    border: 'border-emerald-500/10',
    text: 'text-emerald-300/80',
    dot: 'bg-emerald-400',
  },
  {
    title: 'Native macOS',
    subtitle: 'AppKit · NSRunLoop · NSVisualEffectView · Liquid Glass',
    icon: Sparkles,
    accent: 'from-sky-500/10 to-sky-600/5',
    border: 'border-sky-500/10',
    text: 'text-sky-300/80',
    dot: 'bg-sky-400',
  },
]

export default function Architecture() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: '-80px' })

  return (
    <section id="architecture" className="py-28 md:py-36 relative overflow-hidden">
      <div className="max-w-5xl mx-auto px-6 relative z-10">
        <motion.div
          ref={ref}
          initial={{ opacity: 0, y: 24 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full glass text-[11px] text-orange-300/70 mb-6 tracking-wide uppercase font-medium">
            <Layers size={10} />
            <span>Architecture</span>
          </div>
          <h2 className="text-[2.5rem] md:text-[3rem] font-bold tracking-[-0.02em] leading-[1.1] text-white mb-5">
            Native meets <span className="gradient-text">Chromium</span>
          </h2>
          <p className="text-[15px] text-slate-500 max-w-xl mx-auto leading-[1.7]">
            Soul bridges the best of both worlds: the fluidity of SwiftUI with the compatibility of a real Chromium engine.
          </p>
        </motion.div>

        <div className="max-w-xl mx-auto space-y-3">
          {layers.map((layer, i) => (
            <motion.div
              key={layer.title}
              initial={{ opacity: 0, y: 20 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.5, delay: i * 0.12 }}
              className="relative"
            >
              <div className={`flex items-center gap-4 p-4 rounded-2xl border ${layer.border} bg-gradient-to-r ${layer.accent} backdrop-blur-sm`}>
                <div className="relative">
                  <div className="w-9 h-9 rounded-lg bg-white/[0.04] border border-white/[0.06] flex items-center justify-center">
                    <layer.icon size={16} strokeWidth={1.5} className={layer.text} />
                  </div>
                  <div className={`absolute -top-0.5 -right-0.5 w-2 h-2 rounded-full ${layer.dot} glow-dot`} />
                </div>
                <div>
                  <h3 className="text-[14px] font-semibold text-white/90">{layer.title}</h3>
                  <p className="text-[12px] text-slate-500 mt-0.5">{layer.subtitle}</p>
                </div>
              </div>
              {i < layers.length - 1 && (
                <div className="flex justify-center py-1">
                  <div className="w-px h-4 bg-gradient-to-b from-white/10 to-transparent" />
                </div>
              )}
            </motion.div>
          ))}
        </div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.7 }}
          className="mt-14 grid md:grid-cols-3 gap-3"
        >
          {[
            { label: 'SwiftUI + AppKit', desc: 'Native macOS chrome' },
            { label: 'CEF 148', desc: 'Chromium 148, arm64' },
            { label: '6 Processes', desc: 'Main + GPU + Renderer + Helpers' },
          ].map((item) => (
            <div key={item.label} className="text-center p-5 rounded-2xl glass-card">
              <h4 className="text-[13px] font-semibold text-white/80 mb-1">{item.label}</h4>
              <p className="text-[12px] text-slate-500">{item.desc}</p>
            </div>
          ))}
        </motion.div>
      </div>
    </section>
  )
}
