import { useRef, useState } from 'react'
import { motion, useInView, AnimatePresence } from 'framer-motion'
import { Bot, Code2, ShieldCheck, Sparkles, Terminal, Activity, Send } from 'lucide-react'

const tabs = [
  {
    id: 'ai',
    label: 'AI',
    icon: Bot,
    title: 'Your browser thinks with you',
    description: 'A local Codex assistant that reads pages, automates actions, analyzes your clipboard, and summarizes articles - all without a single byte leaving your machine.',
    highlights: ['Local LLM configurator (Ollama / LM Studio)', 'In-page smart rewrite tool', 'AI-assisted form filler', 'Reader mode summary engine', 'Voice control & transcription'],
    preview: 'ai',
  },
  {
    id: 'dev',
    label: 'Dev',
    icon: Code2,
    title: 'Built for makers',
    description: 'A browser that understands developers. Terminal sidebar, HTTP inspector, responsive canvas, JSON formatter, color picker, and a live console - all natively integrated.',
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

const aiResponses: Record<string, string> = {
  'summarize': 'The article covers three key techniques: MIR inlining, polymorphization, and LLVM pass reordering. Want me to extract code examples?',
  'hello': 'Hi! I\'m Soul, your local AI assistant. I can summarize pages, automate browser actions, and help with code - all running on your machine.',
  'privacy': 'Soul blocks trackers before requests fire, stores passwords in native Keychain, and keeps all AI processing local. No cloud required.',
  'tabs': 'Soul uses a right-hand vertical tab strip with tree hierarchies, workspace audio mixing, and a ⌘K command palette for instant search.',
  'default': 'I can help with that. Soul\'s AI runs entirely locally using Codex, with browser automation, page summaries, and clipboard analysis.',
}

function findResponse(input: string) {
  const lower = input.toLowerCase()
  for (const key of Object.keys(aiResponses)) {
    if (lower.includes(key)) return aiResponses[key]
  }
  return aiResponses.default
}

function PreviewBox({ type }: { type: string }) {
  const [aiInput, setAiInput] = useState('')
  const [aiMessages, setAiMessages] = useState<{role: 'user'|'ai', text: string}[]>([
    { role: 'user', text: 'Summarize this Rust article' },
    { role: 'ai', text: aiResponses.summarize },
  ])
  const [aiTyping, setAiTyping] = useState(false)

  const handleAiSend = () => {
    if (!aiInput.trim()) return
    const userMsg = aiInput.trim()
    setAiMessages(prev => [...prev, { role: 'user', text: userMsg }])
    setAiInput('')
    setAiTyping(true)
    setTimeout(() => {
      setAiMessages(prev => [...prev, { role: 'ai', text: findResponse(userMsg) }])
      setAiTyping(false)
    }, 800)
  }

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

        <div className="flex-1 overflow-y-auto space-y-3 min-h-0">
          <AnimatePresence initial={false}>
            {aiMessages.map((msg, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                className={`flex gap-2 ${msg.role === 'ai' ? 'justify-end' : ''}`}
              >
                {msg.role === 'user' && (
                  <div className="w-5 h-5 rounded-full bg-white/[0.05] flex-shrink-0 mt-0.5" />
                )}
                <div className={`max-w-[88%] px-3 py-2 text-[11px] leading-relaxed rounded-xl ${
                  msg.role === 'ai'
                    ? 'bg-orange-500/[0.06] text-slate-400 rounded-tr-sm border border-orange-500/[0.06]'
                    : 'bg-white/[0.03] text-slate-400 rounded-tl-sm'
                }`}>
                  {msg.text}
                </div>
              </motion.div>
            ))}
            {aiTyping && (
              <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="flex justify-end">
                <div className="bg-orange-500/[0.06] rounded-xl rounded-tr-sm px-3 py-2 border border-orange-500/[0.06]">
                  <div className="flex gap-1">
                    <span className="w-1 h-1 rounded-full bg-slate-500 animate-bounce" style={{ animationDelay: '0ms' }} />
                    <span className="w-1 h-1 rounded-full bg-slate-500 animate-bounce" style={{ animationDelay: '150ms' }} />
                    <span className="w-1 h-1 rounded-full bg-slate-500 animate-bounce" style={{ animationDelay: '300ms' }} />
                  </div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        <div className="mt-3 pt-3 border-t border-white/[0.04]">
          <div className="flex items-center gap-2 bg-white/[0.02] rounded-lg px-3 py-2">
            <input
              value={aiInput}
              onChange={e => setAiInput(e.target.value)}
              onKeyDown={e => e.key === 'Enter' && handleAiSend()}
              placeholder="Ask anything..."
              className="flex-1 bg-transparent text-[11px] text-slate-300 placeholder:text-slate-700 outline-none"
            />
            <button
              onClick={handleAiSend}
              className="text-slate-600 hover:text-orange-400 transition-colors"
            >
              <Send size={12} />
            </button>
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
    <section id="showcase" className="py-24 md:py-32">
      <div className="max-w-5xl mx-auto px-6">
        <motion.div
          ref={ref}
          initial={{ opacity: 0, y: 24 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-14"
        >
          <h2 className="text-4xl md:text-5xl font-bold tracking-[-0.02em] leading-[1.1] text-white mb-4 text-balance">
            Three <span className="gradient-text">pillars</span>
          </h2>
          <p className="text-[14px] text-slate-500 max-w-lg mx-auto leading-[1.7]">
            Try the AI demo. Type a message and see how Soul responds - all simulated locally.
          </p>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="grid lg:grid-cols-2 gap-8 items-start"
        >
          {/* Left: Tab content */}
          <div className="space-y-4">
            <div className="flex gap-1.5 p-1 rounded-xl bg-white/[0.02] border border-white/[0.04]">
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex-1 flex items-center justify-center gap-2 px-4 py-2 rounded-lg text-[13px] font-medium transition-all duration-300 active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-white/10 ${
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
                <h3 className="text-lg font-bold text-white/90">{active.title}</h3>
                <p className="text-[13px] text-slate-500 leading-[1.7]">{active.description}</p>
                <ul className="space-y-2 pt-1">
                  {active.highlights.map((h) => (
                    <li key={h} className="flex items-center gap-2 text-[12px] text-slate-400">
                      <div className="w-[4px] h-[4px] rounded-full bg-orange-400/50 flex-shrink-0" />
                      {h}
                    </li>
                  ))}
                </ul>
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Right: Preview */}
          <div className="relative">
            <div className="absolute -inset-5 bg-gradient-to-br from-orange-500/[0.05] via-transparent to-violet-500/[0.03] blur-3xl rounded-[2.5rem]" />
            <div className="relative rounded-2xl border border-white/[0.06] bg-[#0c0c12] overflow-hidden shadow-2xl shadow-black/50 h-[360px]">
              <AnimatePresence mode="wait">
                <motion.div
                  key={activeTab}
                  initial={{ opacity: 0, x: 12 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -12 }}
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
