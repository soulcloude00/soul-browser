import { useRef } from 'react'
import { motion, useScroll, useTransform } from 'framer-motion'
import { ArrowRight, Globe, Lock, Sparkles, Search, Mic } from 'lucide-react'

const ease = [0.22, 1, 0.36, 1] as const

const tabs = [
  { label: 'soul.dev', active: true },
  { label: 'github.com', active: false },
  { label: 'news.ycombinator.com', active: false },
  { label: 'figma.com', active: false },
]

export default function Hero() {
  const ref = useRef<HTMLDivElement>(null)
  const { scrollYProgress } = useScroll({ target: ref, offset: ['start start', 'end start'] })
  const mockY = useTransform(scrollYProgress, [0, 1], [0, 120])
  const mockRotate = useTransform(scrollYProgress, [0, 1], [0, 4])
  const glowOpacity = useTransform(scrollYProgress, [0, 0.6], [1, 0])

  return (
    <section id="top" ref={ref} className="relative pt-44 pb-10 md:pt-52 overflow-hidden">
      {/* Ember bloom behind the headline */}
      <motion.div
        style={{ opacity: glowOpacity }}
        className="absolute top-[-20%] left-1/2 -translate-x-1/2 w-[1100px] h-[700px] pointer-events-none"
        aria-hidden
      >
        <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_center,rgba(255,92,26,0.14),transparent_60%)]" />
      </motion.div>

      <div className="max-w-7xl mx-auto px-6 lg:px-10 relative">
        {/* Eyebrow */}
        <motion.p
          initial={{ opacity: 0, y: 14 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, ease }}
          className="eyebrow text-center mb-8 flex items-center justify-center gap-3"
        >
          <span className="w-1.5 h-1.5 rounded-full bg-ember animate-pulse-dot" />
          Native macOS &middot; Chromium engine &middot; Local AI
        </motion.p>

        {/* Headline */}
        <h1 className="text-center font-display font-medium tracking-tightest leading-[0.92] text-[clamp(3.2rem,9.5vw,8.5rem)] text-balance">
          <motion.span
            initial={{ opacity: 0, y: 60 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.9, delay: 0.08, ease }}
            className="block"
          >
            The browser
          </motion.span>
          <motion.span
            initial={{ opacity: 0, y: 60 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.9, delay: 0.2, ease }}
            className="block"
          >
            with a{' '}
            <em className="font-serif italic font-normal text-ember">soul</em>
            <span className="text-ember">.</span>
          </motion.span>
        </h1>

        {/* Sub copy */}
        <motion.p
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.38, ease }}
          className="mt-8 mx-auto max-w-xl text-center text-ash text-base md:text-lg leading-relaxed"
        >
          Pure Swift chrome wrapped around a real Chromium engine.
          On-device AI, vertical tabs, 120Hz Metal rendering &mdash;
          and not a single byte of telemetry.
        </motion.p>

        {/* CTAs */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.5, ease }}
          className="mt-10 flex flex-wrap items-center justify-center gap-4"
        >
          <a
            href="https://github.com/soulcloude00/soul-browser"
            target="_blank"
            rel="noopener noreferrer"
            className="group inline-flex items-center gap-2.5 pl-7 pr-6 py-4 rounded-full bg-ember text-void text-[15px] font-semibold glow-ember hover:bg-ember-soft active:scale-[0.97] transition-all duration-300"
          >
            Get Soul for macOS
            <ArrowRight size={17} className="transition-transform duration-300 group-hover:translate-x-1" />
          </a>
          <a
            href="#features"
            className="inline-flex items-center gap-2 px-6 py-4 rounded-full border hairline-strong text-[15px] text-ash hover:text-bone hover:border-bone/40 transition-colors duration-300"
          >
            Explore the craft
          </a>
        </motion.div>

        {/* Browser mockup */}
        <motion.div
          initial={{ opacity: 0, y: 80 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1.1, delay: 0.6, ease }}
          style={{ y: mockY, rotateX: mockRotate, transformPerspective: 1200 }}
          className="relative mt-20 md:mt-28 mx-auto max-w-5xl"
        >
          {/* Halo */}
          <div className="absolute -inset-x-16 -top-16 -bottom-8 bg-[radial-gradient(ellipse_at_top,rgba(255,92,26,0.16),transparent_65%)] pointer-events-none" aria-hidden />

          <div className="relative rounded-2xl border hairline-strong bg-coal shadow-[0_60px_120px_-30px_rgba(0,0,0,0.9)] overflow-hidden">
            {/* Title bar */}
            <div className="flex items-center gap-3 px-5 py-3.5 border-b hairline bg-smoke/60">
              <div className="flex gap-2">
                <span className="w-3 h-3 rounded-full bg-[#ff5f56]" />
                <span className="w-3 h-3 rounded-full bg-[#ffbd2e]" />
                <span className="w-3 h-3 rounded-full bg-[#27c93f]" />
              </div>
              <div className="flex-1 flex justify-center">
                <div className="flex items-center gap-2 px-4 py-1.5 rounded-lg bg-void/60 border hairline text-[12px] text-ash font-mono min-w-[260px] justify-center">
                  <Lock size={11} className="text-ember" />
                  soul.dev
                  <span className="ml-auto text-dim text-[10px]">&#8984;L</span>
                </div>
              </div>
              <div className="w-[52px]" />
            </div>

            <div className="flex">
              {/* Page content */}
              <div className="flex-1 min-h-[340px] md:min-h-[420px] relative bg-gradient-to-b from-coal to-void p-8 md:p-12">
                <p className="eyebrow mb-5">new tab &middot; private by default</p>
                <p className="font-display text-2xl md:text-4xl font-medium tracking-tight leading-tight max-w-md">
                  Ask anything.<br />
                  <span className="font-serif italic text-ember">It never leaves your Mac.</span>
                </p>

                {/* AI bar */}
                <div className="mt-8 flex items-center gap-3 max-w-md px-4 py-3.5 rounded-xl border hairline-strong bg-smoke/70 backdrop-blur">
                  <Sparkles size={15} className="text-ember shrink-0" />
                  <span className="text-[13px] text-ash truncate">
                    Summarize this page with the local model&hellip;
                  </span>
                  <span className="ml-auto flex items-center gap-2 shrink-0">
                    <Mic size={13} className="text-dim" />
                    <Search size={13} className="text-dim" />
                  </span>
                </div>

                <div className="mt-6 flex items-center gap-2 text-[11px] font-mono text-dim">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse-dot" />
                  ollama &middot; llama3 &middot; on-device
                </div>
              </div>

              {/* Right-hand vertical tab sidebar — Soul's signature */}
              <div className="hidden sm:flex w-56 flex-col border-l hairline bg-smoke/40 p-3 gap-1.5">
                <p className="font-mono text-[9px] tracking-[0.28em] uppercase text-dim px-2 py-2">Space &middot; Work</p>
                {tabs.map((t) => (
                  <div
                    key={t.label}
                    className={`flex items-center gap-2.5 px-3 py-2.5 rounded-lg text-[12px] transition-colors ${
                      t.active
                        ? 'bg-ember/10 text-ember border border-ember/25'
                        : 'text-ash hover:bg-bone/5 border border-transparent'
                    }`}
                  >
                    <Globe size={12} className="shrink-0 opacity-70" />
                    <span className="truncate">{t.label}</span>
                  </div>
                ))}
                <div className="mt-auto px-3 py-2.5 rounded-lg border border-dashed hairline-strong text-[11px] text-dim text-center">
                  + new tab
                </div>
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  )
}
