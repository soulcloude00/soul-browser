import { useRef } from 'react'
import { motion, useInView } from 'framer-motion'

const ease = [0.22, 1, 0.36, 1] as const

const layers = [
  {
    name: 'SwiftUI chrome',
    detail: 'RootView · Toolbar · Sidebar · AIPanel · Liquid Glass theme',
    tone: 'border-ember/40 bg-ember/[0.06]',
    tag: 'swift',
  },
  {
    name: 'Obj-C bridge',
    detail: 'SoulBrowserView : NSView — one CEF browser per tab',
    tone: 'border-bone/20 bg-bone/[0.03]',
    tag: 'objc',
  },
  {
    name: 'Chromium via CEF 148',
    detail: 'Dynamically loaded, never linked · 5 helper processes',
    tone: 'border-bone/15 bg-bone/[0.02]',
    tag: 'c++',
  },
  {
    name: 'Metal · Apple Silicon',
    detail: 'Direct GPU compositing · hardware decode · 120Hz',
    tone: 'border-bone/10 bg-void',
    tag: 'gpu',
  },
]

export default function Engine() {
  const ref = useRef(null)
  const inView = useInView(ref, { once: true, margin: '-100px' })

  return (
    <section id="engine" className="py-28 md:py-40 border-t hairline relative overflow-hidden">
      {/* side glow */}
      <div className="absolute top-1/2 -translate-y-1/2 -right-64 w-[600px] h-[600px] bg-[radial-gradient(circle,rgba(255,92,26,0.08),transparent_65%)] pointer-events-none" aria-hidden />

      <div className="max-w-7xl mx-auto px-6 lg:px-10 grid lg:grid-cols-2 gap-16 lg:gap-24 items-center" ref={ref}>
        {/* Copy */}
        <motion.div
          initial={{ opacity: 0, y: 32 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8, ease }}
        >
          <p className="eyebrow mb-6">/ under the hood</p>
          <h2 className="font-display font-medium tracking-tightest leading-[0.95] text-4xl md:text-6xl text-balance">
            A real engine.<br />
            <em className="font-serif italic text-ember">A native heart.</em>
          </h2>
          <p className="mt-7 text-ash text-[15px] md:text-base leading-relaxed max-w-md">
            Soul talks to Chromium through a pure Objective-C bridge — Swift
            never touches C++. The CEF framework is loaded dynamically at
            runtime, never linked, so the chrome stays light and the engine
            stays honest.
          </p>
          <div className="mt-9 flex flex-wrap gap-2.5">
            {['xcodegen', 'cmake', 'libcef_dll_wrapper', 'NSHostingController'].map((t) => (
              <span key={t} className="font-mono text-[11px] px-3 py-1.5 rounded-full border hairline text-ash">
                {t}
              </span>
            ))}
          </div>
        </motion.div>

        {/* Layer stack diagram */}
        <div className="flex flex-col gap-3">
          {layers.map((layer, i) => (
            <motion.div
              key={layer.name}
              initial={{ opacity: 0, x: 48 }}
              animate={inView ? { opacity: 1, x: 0 } : {}}
              transition={{ duration: 0.7, delay: i * 0.12, ease }}
              className={`relative rounded-xl border px-6 py-5 ${layer.tone} hover:translate-x-[-6px] transition-transform duration-500`}
              style={{ marginLeft: `${i * 14}px` }}
            >
              <div className="flex items-center justify-between gap-4">
                <div>
                  <p className="font-display font-medium text-[15px] md:text-base tracking-tight">{layer.name}</p>
                  <p className="mt-1 font-mono text-[11px] text-dim">{layer.detail}</p>
                </div>
                <span className="font-mono text-[10px] uppercase tracking-[0.25em] text-ember shrink-0">{layer.tag}</span>
              </div>
              {i < layers.length - 1 && (
                <span className="absolute left-8 -bottom-3 w-px h-3 bg-bone/15" aria-hidden />
              )}
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}
