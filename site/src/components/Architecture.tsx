import { useRef } from 'react'
import { motion, useInView } from 'framer-motion'
import { Layers, ArrowRightLeft, Monitor, Sparkles } from 'lucide-react'

const layers = [
  {
    title: 'SwiftUI Chrome',
    subtitle: 'RootView · Toolbar · Sidebar · AIPanel · Settings',
    icon: Layers,
    color: 'bg-violet-500/10 border-violet-500/20 text-violet-300',
  },
  {
    title: 'ObjC Bridge',
    subtitle: 'SoulBrowserView header — pure ObjC, Swift-facing',
    icon: ArrowRightLeft,
    color: 'bg-accent-500/10 border-accent-500/20 text-accent-300',
  },
  {
    title: 'CEF Engine',
    subtitle: 'Chromium 148 · CEF 148 · MetalRenderHandler',
    icon: Monitor,
    color: 'bg-emerald-500/10 border-emerald-500/20 text-emerald-300',
  },
  {
    title: 'Native macOS',
    subtitle: 'AppKit · NSRunLoop · NSVisualEffectView · Liquid Glass',
    icon: Sparkles,
    color: 'bg-sky-500/10 border-sky-500/20 text-sky-300',
  },
]

export default function Architecture() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: '-100px' })

  return (
    <section id="architecture" className="py-24 md:py-32 relative overflow-hidden">
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_60%_40%_at_50%_50%,rgba(254,128,16,0.05),transparent)]" />

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        <motion.div
          ref={ref}
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full glass text-xs text-accent-300 mb-6">
            <Layers size={12} />
            <span>Architecture</span>
          </div>
          <h2 className="text-4xl md:text-5xl font-bold tracking-tight mb-4">
            Native meets <span className="gradient-text">Chromium</span>
          </h2>
          <p className="text-lg text-slate-400 max-w-2xl mx-auto">
            Soul bridges the best of both worlds: the fluidity of SwiftUI and AppKit
            with the compatibility of a real Chromium engine.
          </p>
        </motion.div>

        <div className="max-w-3xl mx-auto">
          {layers.map((layer, i) => (
            <motion.div
              key={layer.title}
              initial={{ opacity: 0, x: i % 2 === 0 ? -40 : 40 }}
              animate={isInView ? { opacity: 1, x: 0 } : {}}
              transition={{ duration: 0.5, delay: i * 0.15 }}
              className="relative"
            >
              <div className={`flex items-center gap-4 p-5 rounded-xl border ${layer.color} mb-4 backdrop-blur-sm`}>
                <div className={`w-10 h-10 rounded-lg flex items-center justify-center bg-white/5`}>
                  <layer.icon size={20} strokeWidth={1.5} />
                </div>
                <div>
                  <h3 className="font-semibold text-sm">{layer.title}</h3>
                  <p className="text-xs opacity-70 mt-0.5">{layer.subtitle}</p>
                </div>
              </div>
              {i < layers.length - 1 && (
                <div className="absolute left-1/2 -translate-x-1/2 -bottom-2 w-px h-4 bg-white/10" />
              )}
            </motion.div>
          ))}
        </div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.8 }}
          className="mt-16 grid md:grid-cols-3 gap-6"
        >
          {[
            { label: 'SwiftUI + AppKit', desc: 'Native macOS chrome with Liquid Glass' },
            { label: 'CEF 148 / Chromium 148', desc: 'Latest embedded Chromium, arm64 native' },
            { label: '6 Process Bundles', desc: 'Main + GPU + Plugin + Renderer + Alerts + Helper' },
          ].map((item) => (
            <div key={item.label} className="text-center p-6 rounded-xl glass border border-white/5">
              <h4 className="font-semibold text-slate-200 mb-1">{item.label}</h4>
              <p className="text-sm text-slate-500">{item.desc}</p>
            </div>
          ))}
        </motion.div>
      </div>
    </section>
  )
}
