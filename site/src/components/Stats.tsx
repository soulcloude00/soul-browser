import { useEffect, useRef, useState } from 'react'
import { motion, useInView } from 'framer-motion'

const ease = [0.22, 1, 0.36, 1] as const

const stats = [
  { value: 40, suffix: '%', label: 'less GPU memory than Electron shells' },
  { value: 120, suffix: 'Hz', label: 'ProMotion scrolling on Metal' },
  { value: 3, suffix: '×', label: 'faster page loads with request-level blocking' },
  { value: 0, suffix: '', label: 'bytes of telemetry. Ever.' },
]

function Counter({ target, suffix, start }: { target: number; suffix: string; start: boolean }) {
  const [value, setValue] = useState(0)

  useEffect(() => {
    if (!start) return
    if (target === 0) {
      setValue(0)
      return
    }
    const duration = 1400
    const t0 = performance.now()
    let raf: number
    const tick = (t: number) => {
      const p = Math.min((t - t0) / duration, 1)
      const eased = 1 - Math.pow(1 - p, 4)
      setValue(Math.round(eased * target))
      if (p < 1) raf = requestAnimationFrame(tick)
    }
    raf = requestAnimationFrame(tick)
    return () => cancelAnimationFrame(raf)
  }, [start, target])

  return (
    <span className="tabular-nums">
      {value}
      <span className="text-ember">{suffix}</span>
    </span>
  )
}

export default function Stats() {
  const ref = useRef(null)
  const inView = useInView(ref, { once: true, margin: '-100px' })

  return (
    <section className="border-t hairline" ref={ref}>
      <div className="max-w-7xl mx-auto px-6 lg:px-10 grid grid-cols-2 lg:grid-cols-4">
        {stats.map((s, i) => (
          <motion.div
            key={s.label}
            initial={{ opacity: 0, y: 32 }}
            animate={inView ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.7, delay: i * 0.1, ease }}
            className={`py-14 md:py-20 px-2 md:px-8 ${i > 0 ? 'border-l hairline' : ''} ${i >= 2 ? 'max-lg:border-t max-lg:hairline' : ''} ${i === 2 ? 'max-lg:border-l-0' : ''}`}
          >
            <p className="font-display font-medium tracking-tightest text-5xl md:text-7xl">
              <Counter target={s.value} suffix={s.suffix} start={inView} />
            </p>
            <p className="mt-4 text-[13px] text-ash leading-relaxed max-w-[200px]">{s.label}</p>
          </motion.div>
        ))}
      </div>
    </section>
  )
}
