import { useRef, useState } from 'react'
import { motion, useInView, AnimatePresence } from 'framer-motion'
import { Bot, Code2, Eye, ShieldCheck, Sparkles, Terminal, Activity } from 'lucide-react'

const tabs = [
  {
    id: 'ai',
    label: 'AI',
    icon: Bot,
    title: 'Your browser thinks with you',
    description: 'A local Codex assistant that reads pages, automates actions, analyzes your clipboard, and summarizes articles — all without a single byte leaving your machine.',
    highlights: ['Local LLM configurator (Ollama / LM Studio)', 'In-page smart rewrite tool', 'AI-assisted form filler', 'Reader mode summary engine', 'Voice control & transcription'],
    preview: 'ai',
  },
  {
    id: 'dev',
    label: 'Dev',
    icon: Code2,
    title: 'Built for makers',
    description: 'A browser that understands developers. Terminal sidebar, HTTP inspector, responsive canvas, JSON formatter, color picker, and a live console — all natively integrated.',
    highlights: ['Integrated terminal sidebar', 'HTTP request/response inspector', 'Responsive layout canvas', 'Local SSL certificate manager', 'Web asset downloader'],
    preview: 'dev',
  },
  {
    id: 'privacy',
    label: 'Privacy',
    icon: ShieldCheck,
    title: 'Your data stays yours',
    description: 'Declarative blocklist engine, real-time privacy dashboard, and native Keychain integration. Semantic history lives in a local SQLite vector store.',
    highlights: ['Declarative blocklist engine', 'Real-time privacy dashboard', 'Native Keychain storage', 'LAN sync via Bonjour', 'Offline AI translation'],
    preview: 'privacy',
  },
]

function PreviewBox({ type }: { type: string }) {
  if (type === 'ai') {
    return (
      <div className="h-full flex flex-col p-5">
        <div className="flex items-center gap-2.5 mb-4 pb-3 border-b border-white/[0.04]">
          <div className="w-7 h-7 rounded-full bg-gradient-to-br from-orange-400/20 to-orange-600/10 border border-orange-500/15 flex items-center justify-center">
            <Sparkles size={12} className="text-orange-400" />
          </div>
          <div>
            <div className="text-[13px] font-medium text-white/80">Soul</div>
            <div className="text-[10px] text-slate-600">Running locally on-device</div>
          </div>
          <div className="ml-auto flex items-center gap-1">
            <div className="w-1.5 h-1.5 rounded-full bg-emerald-400" />
            <span className="text-[10px] text-slate-600">Online</span>
          </div>
        </div>
        <div className="space-y-3 flex-1">
          <div className="flex gap-2">
            <div className="w-6 h-6 rounded-full bg-white/[0.05] flex-shrink-0" />
            <div className="bg-white/[0.03] rounded-xl rounded-tl-sm px-3 py-2 text-[11px] text-slate-400 max-w-[88%] leading-relaxed">
              Summarize this article about Rust compiler optimizations
            </div>
          </div>
          <div className="flex gap-2 justify-end">
            <div className="bg-orange-500/[0.06] rounded-xl rounded-tr-sm px-3 py-2 text-[11px] text-slate-400 max-w-[88%] leading-relaxed border border-orange-500/[0.06]">
              The article covers three key techniques: MIR inlining, polymorphization, and LLVM pass reordering. Want me to extract code examples?
            </div>
          </div>
          <div className="flex gap-2">
            <div className="w-6 h-6 rounded-full bg-white/[0.05] flex-shrink-0" />
            <div className="bg-white/[0.03] rounded-xl rounded-tl-sm px-3 py-2 text-[11px] text-slate-400 max-w-[88%]">
              Yes, save them to my notes
            </div>
          </div>
        </div>
        <div className="mt-3 pt-3 border-t border-white/[0.04]">
          <div className="bg-white/[0.02] rounded-lg px-3 py-2 text-[11px] text-slate-600 flex items-center gap-2">
            <Sparkles size={10} className="text-slate-700" />
            <span>Ask anything...</span>
          </div>
        </div>
      </div>
    )
  }

  if (type === 'dev') {
    return (
      <div className="h-full flex flex-col p-5 font-mono text-[11px]">
        <div className="flex items-center gap-2 mb-3 text-slate-500 text-[10px] uppercase tracking-wider">
          <Terminal size={11} />
          <span>Terminal</span>
          <span className="ml-auto text-slate-700">zsh</span>
        </div>
        <div className="space-y-1 flex-1 overflow-hidden">
          <div className="text-slate-600"><span className="text-emerald-400/80">➜</span> <span className="text-cyan-400/80">~</span> curl -I https://api.github.com</div>
          <div className="text-slate-600 pl-4">HTTP/2 200</div>
          <div className="text-slate-600 pl-4">server: GitHub.com</div>
          <div className="text-slate-600 pl-4">content-type: application/json</div>
          <div className="text-slate-600 pl-4">x-ratelimit-limit: 60</div>
          <div className="text-slate-600 pl-4">...</div>
          <div className="text-slate-600 mt-2"><span className="text-emerald-400/80">➜</span> <span className="text-cyan-400/80">~</span> <span className="animate-pulse text-slate-500">█</span></div>
        </div>
        <div className="mt-3 grid grid-cols-3 gap-2">
          {[
            { val: '200ms', label: 'Latency', color: 'text-emerald-400/80' },
            { val: '12KB', label: 'Size', color: 'text-sky-400/80' },
            { val: 'H2', label: 'Protocol', color: 'text-violet-400/80' },
          ].map((s) => (
            <div key={s.label} className="bg-white/[0.02] rounded-lg p-2 text-center border border-white/[0.03]">
              <div className={`${s.color} font-semibold text-[12px]`}>{s.val}</div>
              <div className="text-[10px] text-slate-700">{s.label}</div>
            </div>
          ))}
        </div>
      </div>
    )
  }

  return (
    <div className="h-full flex flex-col p-5">
      <div className="flex items-center justify-between mb-4 pb-3 border-b border-white/[0.04]">
        <div className="flex items-center gap-2">
          <ShieldCheck size={14} className="text-emerald-400/80" />
          <span className="text-[13px] font-medium text-white/80">Privacy</span>
        </div>
        <span className="text-[10px] text-emerald-400/80 bg-emerald-500/[0.08] px-2 py-0.5 rounded-full border border-emerald-500/10">Protected</span>
      </div>
      <div className="space-y-2 flex-1">
        {[
          { label: 'Trackers blocked', value: '847', color: 'text-rose-400/80', bg: 'bg-rose-500/[0.06]' },
          { label: 'Cookies secured', value: '12', color: 'text-amber-400/80', bg: 'bg-amber-500/[0.06]' },
          { label: 'HTTPS upgrades', value: '203', color: 'text-emerald-400/80', bg: 'bg-emerald-500/[0.06]' },
        ].map((stat) => (
          <div key={stat.label} className="flex items-center justify-between p-3 rounded-xl bg-white/[0.02] border border-white/[0.03]">
            <div className="flex items-center gap-2.5">
              <div className={`w-7 h-7 rounded-lg ${stat.bg} flex items-center justify-center`}>
                <Activity size={12} className={stat.color} />
              </div>
              <span className="text-[12px] text-slate-400">{stat.label}</span>
            </div>
            <span className="text-[13px] font-semibold text-white/80">{stat.value}</span>
          </div>
        ))}
      </div>
      <div className="mt-3 p-3 rounded-xl bg-emerald-500/[0.03] border border-emerald-500/[0.06]">
        <div className="text-[11px] text-emerald-400/70">No data sent to external servers in this session.</div>
      </div>
    </div>
  )
}

export default function Showcase() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: '-80px' })
  const [activeTab, setActiveTab] = useState('ai')

  const active = tabs.find((t) => t.id === activeTab)!

  return (
    <section id="showcase" className="py-28 md:py-36">
      <div className="max-w-6xl mx-auto px-6">
        <motion.div
          ref={ref}
          initial={{ opacity: 0, y: 24 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full glass text-[11px] text-orange-300/70 mb-6 tracking-wide uppercase font-medium">
            <Eye size={10} />
            <span>Showcase</span>
          </div>
          <h2 className="text-[2.5rem] md:text-[3rem] font-bold tracking-[-0.02em] leading-[1.1] text-white mb-5">
            Three <span className="gradient-text">pillars</span>
          </h2>
          <p className="text-[15px] text-slate-500 max-w-xl mx-auto leading-[1.7]">
            Intelligence, craft, and privacy — each deeply integrated into every interaction.
          </p>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="grid lg:grid-cols-2 gap-10 items-start"
        >
          {/* Left: Tab content */}
          <div className="space-y-5">
            <div className="flex gap-1.5 p-1 rounded-xl bg-white/[0.02] border border-white/[0.04]">
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex-1 flex items-center justify-center gap-2 px-4 py-2 rounded-lg text-[13px] font-medium transition-all duration-300 ${
                    activeTab === tab.id
                      ? 'bg-white/[0.06] text-white'
                      : 'text-slate-600 hover:text-slate-300'
                  }`}
                >
                  <tab.icon size={13} />
                  <span>{tab.label}</span>
                </button>
              ))}
            </div>

            <AnimatePresence mode="wait">
              <motion.div
                key={activeTab}
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -8 }}
                transition={{ duration: 0.25 }}
                className="space-y-4"
              >
                <h3 className="text-xl font-bold text-white/90">{active.title}</h3>
                <p className="text-[14px] text-slate-500 leading-[1.7]">{active.description}</p>
                <ul className="space-y-2.5 pt-1">
                  {active.highlights.map((h) => (
                    <li key={h} className="flex items-center gap-2.5 text-[13px] text-slate-400">
                      <div className="w-[5px] h-[5px] rounded-full bg-orange-400/60 flex-shrink-0" />
                      {h}
                    </li>
                  ))}
                </ul>
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Right: Preview */}
          <div className="relative">
            <div className="absolute -inset-6 bg-gradient-to-br from-orange-500/[0.06] via-transparent to-violet-500/[0.04] blur-3xl rounded-[2.5rem]" />
            <div className="relative rounded-2xl border border-white/[0.06] bg-[#0c0c12] overflow-hidden shadow-2xl shadow-black/50 h-[380px]">
              <AnimatePresence mode="wait">
                <motion.div
                  key={activeTab}
                  initial={{ opacity: 0, x: 16 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -16 }}
                  transition={{ duration: 0.25 }}
                  className="h-full"
                >
                  <PreviewBox type={active.preview} />
                </motion.div>
              </AnimatePresence>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  )
}
