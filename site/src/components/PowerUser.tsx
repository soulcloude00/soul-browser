import { useRef } from 'react'
import { motion, useInView } from 'framer-motion'
import { TerminalSquare, Network, FileCode2, Layers } from 'lucide-react'

const tools = [
  {
    icon: TerminalSquare,
    title: 'Integrated Terminal Sidebar',
    desc: 'Run git, compile servers, or execute scripts in a native PTY right next to your web view.',
  },
  {
    icon: Network,
    title: 'HTTP Request Inspector',
    desc: 'Intercept, modify, and replay API queries natively without heavy DevTools overlays.',
  },
  {
    icon: FileCode2,
    title: 'Local Script Engine',
    desc: 'Write custom JavaScript enhancements that execute securely in isolated renderer contexts.',
  },
  {
    icon: Layers,
    title: 'Localhost Dashboard',
    desc: 'A status bar widget that auto-detects active local dev servers (3000, 8080) for instant access.',
  }
]

export default function PowerUser() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: '-80px' })

  return (
    <section className="py-24 md:py-32 bg-[#12110e] text-white relative overflow-hidden">
      {/* Background Grid */}
      <div className="absolute inset-0 bg-[linear-gradient(rgba(255,255,255,0.02)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.02)_1px,transparent_1px)] bg-[size:32px_32px] [mask-image:radial-gradient(ellipse_80%_80%_at_50%_0%,black,transparent)] opacity-50" />
      
      <div className="max-w-6xl mx-auto px-6 relative z-10">
        <div className="grid lg:grid-cols-[1fr_1.2fr] gap-16 items-center">
          
          <motion.div
            ref={ref}
            initial={{ opacity: 0, x: -24 }}
            animate={isInView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
          >
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-orange-500/10 border border-orange-500/20 text-orange-400 text-xs font-semibold tracking-wide uppercase mb-6">
              <TerminalSquare size={14} />
              <span>Developer First</span>
            </div>
            <h2 className="font-display font-semibold text-4xl md:text-5xl tracking-[-0.03em] leading-[1.05] text-white mb-6 text-balance">
              Engineered for the <span className="text-orange-500">power user</span>.
            </h2>
            <p className="text-lg text-zinc-400 leading-relaxed mb-10">
              Soul ships with a suite of native tools designed for builders. Stop juggling separate terminal windows, API clients, and browser tabs.
            </p>

            <div className="space-y-6">
              {tools.map((tool, i) => (
                <motion.div 
                  key={tool.title}
                  initial={{ opacity: 0, y: 10 }}
                  animate={isInView ? { opacity: 1, y: 0 } : {}}
                  transition={{ duration: 0.5, delay: i * 0.1 + 0.3 }}
                  className="flex gap-4"
                >
                  <div className="w-10 h-10 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center shrink-0">
                    <tool.icon size={18} className="text-zinc-300" />
                  </div>
                  <div>
                    <h4 className="text-base font-semibold text-zinc-100 mb-1">{tool.title}</h4>
                    <p className="text-[13.5px] text-zinc-500 leading-relaxed">{tool.desc}</p>
                  </div>
                </motion.div>
              ))}
            </div>
          </motion.div>

          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={isInView ? { opacity: 1, scale: 1 } : {}}
            transition={{ duration: 0.8, delay: 0.2, ease: [0.22, 1, 0.36, 1] }}
            className="relative"
          >
            <div className="relative rounded-2xl border border-white/10 bg-[#0c0b09] overflow-hidden shadow-2xl h-[500px] flex flex-col">
              {/* Fake Terminal Header */}
              <div className="h-10 border-b border-white/10 bg-[#14130f] flex items-center px-4 gap-4 shrink-0">
                <div className="flex gap-1.5 opacity-60">
                  <div className="w-3 h-3 rounded-full bg-[#ff5f56]" />
                  <div className="w-3 h-3 rounded-full bg-[#ffbd2e]" />
                  <div className="w-3 h-3 rounded-full bg-[#27c93f]" />
                </div>
                <div className="text-[11px] font-mono text-zinc-500">soul-terminal — bash — 80x24</div>
              </div>
              
              {/* Fake Terminal Content */}
              <div className="flex-1 p-5 font-mono text-[12px] text-zinc-300 space-y-2 overflow-hidden bg-[#0c0b09]">
                <div className="flex gap-2">
                  <span className="text-emerald-400">➜</span>
                  <span className="text-cyan-400">soul-browser</span>
                  <span className="text-zinc-500">git:(main)</span>
                  <span className="text-zinc-300">npm run dev</span>
                </div>
                <div className="text-zinc-500 mt-2">
                  <br />
                  &gt; soul-browser-site@1.0.0 dev<br />
                  &gt; vite<br />
                  <br />
                  &nbsp;&nbsp;VITE v5.4.21 ready in 250 ms<br />
                  <br />
                  &nbsp;&nbsp;➜ Local: http://localhost:5173/<br />
                  &nbsp;&nbsp;➜ Network: use --host to expose<br />
                </div>
                <br />
                <div className="flex gap-2 items-center">
                  <span className="text-emerald-400">➜</span>
                  <span className="text-cyan-400">soul-browser</span>
                  <span className="text-zinc-500">git:(main)</span>
                  <span className="w-2 h-4 bg-zinc-400 animate-pulse inline-block ml-1" />
                </div>
              </div>

              {/* Absolute Overlay Widget (Localhost Dashboard) */}
              <div className="absolute bottom-6 right-6 p-3 rounded-xl bg-white/10 backdrop-blur-md border border-white/20 shadow-2xl flex items-center gap-3">
                <div className="relative flex items-center justify-center w-8 h-8 rounded-lg bg-emerald-500/20">
                  <div className="absolute w-2.5 h-2.5 rounded-full bg-emerald-500 animate-ping opacity-75" />
                  <div className="relative w-2.5 h-2.5 rounded-full bg-emerald-500" />
                </div>
                <div className="pr-2">
                  <div className="text-[10px] font-semibold uppercase tracking-wider text-zinc-300">Local Server Active</div>
                  <div className="text-[12px] font-mono text-emerald-400 mt-0.5">localhost:5173</div>
                </div>
              </div>
            </div>
            
            {/* Ambient glow */}
            <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-3/4 h-3/4 bg-orange-500/20 blur-[100px] -z-10 rounded-full" />
          </motion.div>
        </div>
      </div>
    </section>
  )
}
