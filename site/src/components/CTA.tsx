import { useRef } from 'react'
import { motion, useInView } from 'framer-motion'
import { ArrowRight } from 'lucide-react'

const ease = [0.22, 1, 0.36, 1] as const

export default function CTA() {
  const ref = useRef(null)
  const inView = useInView(ref, { once: true, margin: '-100px' })

  return (
    <section ref={ref} className="relative py-32 md:py-48 border-t hairline overflow-hidden">
      {/* Bloom */}
      <div className="absolute bottom-[-40%] left-1/2 -translate-x-1/2 w-[1200px] h-[800px] bg-[radial-gradient(ellipse_at_center,rgba(255,92,26,0.16),transparent_60%)] pointer-events-none" aria-hidden />

      <div className="max-w-7xl mx-auto px-6 lg:px-10 text-center relative">
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease }}
          className="eyebrow mb-8"
        >
          / open source &middot; free forever
        </motion.p>

        <motion.h2
          initial={{ opacity: 0, y: 40 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.9, delay: 0.1, ease }}
          className="font-display font-medium tracking-tightest leading-[0.92] text-[clamp(2.8rem,8vw,7rem)] text-balance"
        >
          Your Mac deserves<br />
          <em className="font-serif italic text-ember">better.</em>
        </motion.h2>

        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8, delay: 0.25, ease }}
          className="mt-12 flex flex-wrap items-center justify-center gap-4"
        >
          <a
            href="https://github.com/soulcloude00/soul-browser"
            target="_blank"
            rel="noopener noreferrer"
            className="group inline-flex items-center gap-2.5 pl-8 pr-7 py-4.5 px-8 py-4 rounded-full bg-bone text-void text-[15px] font-semibold hover:bg-white active:scale-[0.97] transition-all duration-300"
          >
            Star on GitHub
            <ArrowRight size={17} className="transition-transform duration-300 group-hover:translate-x-1" />
          </a>
          <span className="font-mono text-[11px] text-dim tracking-[0.18em] uppercase">
            macOS 26+ &middot; Apple Silicon
          </span>
        </motion.div>
      </div>
    </section>
  )
}
