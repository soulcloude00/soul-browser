import { useEffect, useRef, useState } from 'react'
import { motion, useInView, AnimatePresence } from 'framer-motion'
import { Search, ArrowRight, Globe, Sparkles, Moon, History, PanelRight } from 'lucide-react'

const ease = [0.22, 1, 0.36, 1] as const

const queries = ['summarize this page', 'switch to focus mode', 'find that rust article', 'toggle dark mode']

const results = [
  { icon: Sparkles, label: 'Ask local AI', hint: 'on-device' },
  { icon: History, label: 'Semantic history search', hint: '⌘Y' },
  { icon: PanelRight, label: 'Toggle sidebar', hint: '⌘\\' },
  { icon: Moon, label: 'Focus mode', hint: '⌘.' },
  { icon: Globe, label: 'Open in new space', hint: '⌘⇧N' },
]

function useTypewriter(words: string[]) {
  const [text, setText] = useState('')
  const [wordIdx, setWordIdx] = useState(0)

  useEffect(() => {
    const word = words[wordIdx % words.length]
    let i = 0
    let cancelled = false
    let timer: ReturnType<typeof setTimeout>

    const type = () => {
      if (cancelled) return
      if (i <= word.length) {
        setText(word.slice(0, i))
        i += 1
        timer = setTimeout(type, 55)
      } else {
        timer = setTimeout(() => {
          if (!cancelled) setWordIdx((w) => w + 1)
        }, 1800)
      }
    }
    type()
    return () => {
      cancelled = true
      clearTimeout(timer)
    }
  }, [wordIdx, words])

  return text
}

export default function Showcase() {
  const ref = useRef(null)
  const inView = useInView(ref, { once: true, margin: '-100px' })
  const typed = useTypewriter(queries)

  return (
    <section id="command" className="py-28 md:py-40 border-t hairline relative overflow-hidden">
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[900px] h-[500px] bg-[radial-gradient(ellipse_at_top,rgba(255,92,26,0.07),transparent_60%)] pointer-events-none" aria-hidden />

      <div className="max-w-7xl mx-auto px-6 lg:px-10" ref={ref}>
        <motion.div
          initial={{ opacity: 0, y: 32 }}
          animate={inView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.8, ease }}
          className="text-center mb-14 md:mb-20"
        >
          <p className="eyebrow mb-6">/ one keystroke away</p>
          <h2 className="font-display font-medium tracking-tightest leading-[0.95] text-4xl md:text-6xl text-balance">
            Everything answers to{' '}
            <em className="font-serif italic text-ember">&#8984;K</em>
          </h2>
          <p className="mt-6 mx-auto max-w-md text-ash text-[15px] leading-relaxed">
            Tabs, history, settings, AI — one palette commands the entire
            browser. Type what you mean; Soul figures out the rest.
          </p>
        </motion.div>

        {/* Command palette mockup */}
        <motion.div
          initial={{ opacity: 0, y: 48, scale: 0.97 }}
          animate={inView ? { opacity: 1, y: 0, scale: 1 } : {}}
          transition={{ duration: 0.9, delay: 0.15, ease }}
          className="mx-auto max-w-2xl rounded-2xl border hairline-strong bg-coal/90 backdrop-blur-xl shadow-[0_50px_100px_-30px_rgba(0,0,0,0.9)] overflow-hidden"
        >
          <div className="flex items-center gap-3 px-6 py-5 border-b hairline">
            <Search size={17} className="text-ember shrink-0" />
            <span className="text-[15px] text-bone font-mono">
              {typed}
              <span className="inline-block w-[2px] h-[1.1em] bg-ember align-middle ml-0.5 animate-pulse" />
            </span>
            <span className="ml-auto font-mono text-[10px] text-dim border hairline rounded px-2 py-1">ESC</span>
          </div>
          <div className="p-2.5">
            <AnimatePresence>
              {results.map((r, i) => (
                <motion.div
                  key={r.label}
                  initial={{ opacity: 0, x: -12 }}
                  animate={inView ? { opacity: 1, x: 0 } : {}}
                  transition={{ duration: 0.5, delay: 0.35 + i * 0.08, ease }}
                  className={`group flex items-center gap-3.5 px-4 py-3 rounded-xl cursor-pointer transition-colors duration-200 ${
                    i === 0 ? 'bg-ember/10 border border-ember/25' : 'hover:bg-bone/[0.04] border border-transparent'
                  }`}
                >
                  <r.icon size={15} className={i === 0 ? 'text-ember' : 'text-ash'} />
                  <span className={`text-[13.5px] ${i === 0 ? 'text-bone' : 'text-ash'}`}>{r.label}</span>
                  <span className="ml-auto font-mono text-[10px] text-dim">{r.hint}</span>
                  <ArrowRight size={12} className="text-dim opacity-0 group-hover:opacity-100 transition-opacity" />
                </motion.div>
              ))}
            </AnimatePresence>
          </div>
          <div className="px-6 py-3.5 border-t hairline flex items-center gap-4 font-mono text-[10px] text-dim">
            <span>&#8593;&#8595; navigate</span>
            <span>&#9166; select</span>
            <span className="ml-auto flex items-center gap-1.5">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse-dot" />
              local model ready
            </span>
          </div>
        </motion.div>
      </div>
    </section>
  )
}
