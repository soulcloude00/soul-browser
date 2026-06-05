import { useRef } from 'react'
import { motion, useInView } from 'framer-motion'
import { Layers, ArrowRightLeft, Monitor, Sparkles } from 'lucide-react'

const layers = [
  {
    title: 'SwiftUI Chrome',
    subtitle: 'RootView, Toolbar, Sidebar, AIPanel, Settings',
    icon: Layers,
  },
  {
    title: 'ObjC Bridge',
    subtitle: 'SoulBrowserView header: pure ObjC, Swift-facing',
    icon: ArrowRightLeft,
  },
  {
    title: 'CEF Engine',
    subtitle: 'Chromium 148, CEF 148, MetalRenderHandler',
    icon: Monitor,
  },
  {
    title: 'Native macOS',
    subtitle: 'AppKit, NSRunLoop, NSVisualEffectView, Liquid Glass',
    icon: Sparkles,
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
          className="mb-16"
        >
          <h2 className="font-display font-semibold text-4xl md:text-5xl tracking-[-0.03em] leading-[1.02] text-white mb-5 text-balance">
            Native meets <span className="text-orange-400">Chromium</span>
          </h2>
          <p className="text-base text-slate-400 max-w-xl leading-[1.6]">
            Soul bridges the best of both worlds: the fluidity of SwiftUI with the compatibility of a real Chromium engine.
          </p>
        </motion.div>

        <div className="max-w-xl space-y-3">
          {layers.map((layer, i) => (
            <motion.div
              key={layer.title}
              initial={{ opacity: 0, y: 20 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ duration: 0.5, delay: i * 0.12 }}
              className="relative"
            >
              <div className="group flex items-center gap-4 p-4 rounded-2xl panel">
                <div className="flex items-center justify-center w-10 h-10 rounded-xl bg-orange-500/[0.06] border border-orange-500/15 flex-shrink-0">
                  <layer.icon size={17} strokeWidth={1.75} className="text-orange-400" />
                </div>
                <div className="min-w-0">
                  <h3 className="text-sm font-semibold text-white/90">{layer.title}</h3>
                  <p className="text-xs text-slate-500 mt-0.5 font-mono tnum truncate">{layer.subtitle}</p>
                </div>
                <span className="ml-auto text-xs font-mono text-slate-700 tabular-nums">{String(i + 1).padStart(2, '0')}</span>
              </div>
              {i < layers.length - 1 && (
                <div className="flex pl-9 py-1">
                  <div className="w-px h-4 bg-white/10" />
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
            { label: '6 Processes', desc: 'Main, GPU, Renderer, Helpers' },
          ].map((item) => (
            <div key={item.label} className="p-5 rounded-2xl panel">
              <h4 className="text-sm font-semibold text-white/85 mb-1">{item.label}</h4>
              <p className="text-xs text-slate-500 leading-relaxed">{item.desc}</p>
            </div>
          ))}
        </motion.div>
      </div>
    </section>
  )
}
