import { useRef, useState } from 'react'
import { motion, useInView, AnimatePresence } from 'framer-motion'
import { Bot, Code2, Eye, ShieldCheck, Sparkles } from 'lucide-react'

const tabs = [
  {
    id: 'ai',
    label: 'AI Assistant',
    icon: Bot,
    title: 'Your browser thinks with you',
    description: 'Soul ships with a local Codex assistant that can read pages, automate browser actions, analyze clipboard content, and summarize articles — all without sending data to the cloud.',
    highlights: ['Local LLM configurator (Ollama / LM Studio)', 'In-page smart rewrite tool', 'AI-assisted form filler', 'Reader mode summary engine', 'Voice control & transcription'],
    preview: 'ai',
  },
  {
    id: 'dev',
    label: 'Developer Tools',
    icon: Code2,
    title: 'Built for makers',
    description: 'A browser that understands developers. Terminal sidebar, HTTP inspector, responsive canvas, JSON formatter, color picker, and a live console stream — all natively integrated.',
    highlights: ['Integrated terminal sidebar', 'HTTP request/response inspector', 'Responsive layout canvas', 'Local SSL certificate manager', 'Web asset downloader'],
    preview: 'dev',
  },
  {
    id: 'privacy',
    label: 'Privacy',
    icon: ShieldCheck,
    title: 'Your data stays yours',
    description: 'Declarative blocklist engine, real-time privacy dashboard, and native Keychain integration. Semantic history lives in a local SQLite vector store — no cloud required.',
    highlights: ['Declarative blocklist engine', 'Real-time privacy dashboard', 'Native Keychain storage', 'LAN sync via Bonjour', 'Offline AI translation'],
    preview: 'privacy',
  },
]

function PreviewBox({ type }: { type: string }) {
  if (type === 'ai') {
    return (
      <div className="h-full flex flex-col p-5">
        <div className="flex items-center gap-3 mb-4 pb-3 border-b border-white/5">
          <div className="w-8 h-8 rounded-full bg-accent-500/20 flex items-center justify-center">
            <Sparkles size={14} className="text-accent-400" />
          </div>
          <div>
            <div className="text-sm font-medium text-slate-200">Soul Assistant</div>
            <div className="text-xs text-slate-500">Running locally</div>
          </div>
        </div>
        <div className="space-y-3 flex-1">
          <div className="flex gap-2">
            <div className="w-6 h-6 rounded-full bg-white/10 flex-shrink-0" />
            <div className="bg-white/5 rounded-xl rounded-tl-sm px-3 py-2 text-xs text-slate-300 max-w-[85%]">
              Summarize this article about Rust compiler optimizations
            </div>
          </div>
          <div className="flex gap-2 justify-end">
            <div className="bg-accent-500/10 rounded-xl rounded-tr-sm px-3 py-2 text-xs text-slate-300 max-w-[85%] border border-accent-500/10">
              The article covers three key techniques: MIR inlining, polymorphization, and LLVM pass reordering. Would you like me to extract code examples?
            </div>
          </div>
          <div className="flex gap-2">
            <div className="w-6 h-6 rounded-full bg-white/10 flex-shrink-0" />
            <div className="bg-white/5 rounded-xl rounded-tl-sm px-3 py-2 text-xs text-slate-300 max-w-[85%]">
              Yes, and save them to my notes
            </div>
          </div>
        </div>
        <div className="mt-3 pt-3 border-t border-white/5">
          <div className="bg-white/5 rounded-lg px-3 py-2 text-xs text-slate-500 flex items-center gap-2">
            <Sparkles size={12} className="text-slate-600" />
            <span>Ask anything...</span>
          </div>
        </div>
      </div>
    )
  }

  if (type === 'dev') {
    return (
      <div className="h-full flex flex-col p-5 font-mono text-xs">
        <div className="flex items-center gap-2 mb-3 text-slate-400 text-[10px] uppercase tracking-wider">
          <Code2 size={12} />
          <span>Terminal</span>
          <span className="ml-auto text-slate-600">zsh</span>
        </div>
        <div className="space-y-1 flex-1 overflow-hidden">
          <div className="text-slate-500"><span className="text-emerald-400">➜</span> <span className="text-cyan-400">~</span> curl -I https://api.github.com</div>
          <div className="text-slate-500">HTTP/2 200</div>
          <div className="text-slate-500">server: GitHub.com</div>
          <div className="text-slate-500">content-type: application/json</div>
          <div className="text-slate-500">x-ratelimit-limit: 60</div>
          <div className="text-slate-500">...</div>
          <div className="text-slate-500 mt-2"><span className="text-emerald-400">➜</span> <span className="text-cyan-400">~</span> <span className="animate-pulse">█</span></div>
        </div>
        <div className="mt-3 grid grid-cols-3 gap-2">
          <div className="bg-white/[0.03] rounded p-2 text-center">
            <div className="text-emerald-400 font-semibold">200ms</div>
            <div className="text-[10px] text-slate-600">Latency</div>
          </div>
          <div className="bg-white/[0.03] rounded p-2 text-center">
            <div className="text-sky-400 font-semibold">12KB</div>
            <div className="text-[10px] text-slate-600">Size</div>
          </div>
          <div className="bg-white/[0.03] rounded p-2 text-center">
            <div className="text-violet-400 font-semibold">H2</div>
            <div className="text-[10px] text-slate-600">Protocol</div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="h-full flex flex-col p-5">
      <div className="flex items-center justify-between mb-4 pb-3 border-b border-white/5">
        <div className="flex items-center gap-2">
          <ShieldCheck size={16} className="text-emerald-400" />
          <span className="text-sm font-medium text-slate-200">Privacy Dashboard</span>
        </div>
        <span className="text-xs text-emerald-400 bg-emerald-500/10 px-2 py-0.5 rounded-full">Protected</span>
      </div>
      <div className="space-y-3 flex-1">
        {[
          { label: 'Trackers blocked', value: '847', icon: 'bg-rose-500/10 text-rose-400' },
          { label: 'Cookies secured', value: '12', icon: 'bg-amber-500/10 text-amber-400' },
          { label: 'HTTPS upgrades', value: '203', icon: 'bg-emerald-500/10 text-emerald-400' },
        ].map((stat) => (
          <div key={stat.label} className="flex items-center justify-between p-3 rounded-lg bg-white/[0.03]">
            <div className="flex items-center gap-3">
              <div className={`w-8 h-8 rounded-lg flex items-center justify-center text-xs ${stat.icon}`}>
                <ShieldCheck size={14} />
              </div>
              <span className="text-sm text-slate-300">{stat.label}</span>
            </div>
            <span className="text-sm font-semibold text-slate-100">{stat.value}</span>
          </div>
        ))}
      </div>
      <div className="mt-3 p-3 rounded-lg bg-emerald-500/5 border border-emerald-500/10">
        <div className="text-xs text-emerald-300">No data sent to external servers in this session.</div>
      </div>
    </div>
  )
}

export default function Showcase() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: '-100px' })
  const [activeTab, setActiveTab] = useState('ai')

  const active = tabs.find((t) => t.id === activeTab)!

  return (
    <section id="showcase" className="py-24 md:py-32">
      <div className="max-w-7xl mx-auto px-6">
        <motion.div
          ref={ref}
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full glass text-xs text-accent-300 mb-6">
            <Eye size={12} />
            <span>Deep Dive</span>
          </div>
          <h2 className="text-4xl md:text-5xl font-bold tracking-tight mb-4">
            See it in <span className="gradient-text">action</span>
          </h2>
          <p className="text-lg text-slate-400 max-w-2xl mx-auto">
            Three pillars that define the Soul experience: intelligence, craft, and privacy.
          </p>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="grid lg:grid-cols-2 gap-8 items-start"
        >
          {/* Left: Tab content */}
          <div className="space-y-6">
            <div className="flex gap-2 p-1 rounded-xl bg-white/[0.03] border border-white/5">
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex-1 flex items-center justify-center gap-2 px-4 py-2.5 rounded-lg text-sm font-medium transition-all ${
                    activeTab === tab.id
                      ? 'bg-white/10 text-white'
                      : 'text-slate-500 hover:text-slate-300'
                  }`}
                >
                  <tab.icon size={14} />
                  <span className="hidden sm:inline">{tab.label}</span>
                </button>
              ))}
            </div>

            <AnimatePresence mode="wait">
              <motion.div
                key={activeTab}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                transition={{ duration: 0.3 }}
                className="space-y-4"
              >
                <h3 className="text-2xl font-bold text-slate-100">{active.title}</h3>
                <p className="text-slate-400 leading-relaxed">{active.description}</p>
                <ul className="space-y-3">
                  {active.highlights.map((h) => (
                    <li key={h} className="flex items-center gap-3 text-sm text-slate-300">
                      <div className="w-1.5 h-1.5 rounded-full bg-accent-400 flex-shrink-0" />
                      {h}
                    </li>
                  ))}
                </ul>
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Right: Preview */}
          <div className="relative">
            <div className="absolute -inset-4 bg-gradient-to-br from-accent-500/10 to-transparent rounded-3xl blur-2xl" />
            <div className="relative rounded-2xl border border-white/10 bg-slate-900/80 backdrop-blur-xl overflow-hidden shadow-2xl h-[420px]">
              <AnimatePresence mode="wait">
                <motion.div
                  key={activeTab}
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -20 }}
                  transition={{ duration: 0.3 }}
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
