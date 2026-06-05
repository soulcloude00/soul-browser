import { useRef, useState, useEffect } from 'react'
import { motion, AnimatePresence, useInView } from 'framer-motion'
import { Bot, Code2, ShieldCheck, Sparkles, Send, Check, Trash2, Edit2, AlertTriangle, Shield } from 'lucide-react'

const tabs = [
  {
    id: 'ai',
    label: 'Local AI',
    icon: Bot,
    title: 'Your browser thinks with you',
    description: 'A local Codex assistant that reads pages, automates actions, analyzes your clipboard, and summarizes articles - all without a single byte leaving your machine.',
    highlights: [
      'Local LLM integrations (Ollama, LM Studio)',
      'Adjustable Reasoning Effort (Low, Med, High)',
      'In-page smart rewrite toolbar',
      'Reader mode summary engine',
      '100% private: no data sent to cloud servers'
    ],
    preview: 'ai',
  },
  {
    id: 'dev',
    label: 'Cookie Editor',
    icon: Code2,
    title: 'Built-in storage control',
    description: 'A first-class utility panel for developers. Directly view, filter, modify, or delete cookies, localStorage, and sessionStorage keys for any tab in real time.',
    highlights: [
      '380pt native sidebar layout (⌘, to toggle)',
      'Live search filter for storage keys',
      'One-click values editing and cookie injection',
      'Session isolation per browser tab container',
      'Secure credential state visualizer'
    ],
    preview: 'dev',
  },
  {
    id: 'privacy',
    label: 'Privacy Shield',
    icon: ShieldCheck,
    title: 'Your data stays yours',
    description: 'Declarative blocklist engine, real-time privacy dashboard, and fingerprint randomization protecting Canvas and WebGL contexts.',
    highlights: [
      'HTTPS-Only automatic redirection upgrades',
      'Canvas entropy noise perturbations',
      'WebGL renderer vendor spoofing (Apple GPU)',
      'Telemetry bypass & tracking scripts blocklist',
      'Local SQLite vector store for semantic history'
    ],
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
  // --- AI SIMULATOR STATE ---
  const [aiInput, setAiInput] = useState('')
  const [reasoning, setReasoning] = useState<'low' | 'med' | 'high'>('med')
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

    // Simulate thinking delay based on reasoning effort
    const delay = reasoning === 'low' ? 400 : reasoning === 'med' ? 800 : 1500
    setTimeout(() => {
      setAiMessages(prev => [...prev, { role: 'ai', text: findResponse(userMsg) }])
      setAiTyping(false)
    }, delay)
  }

  // --- COOKIE EDITOR STATE ---
  const [cookies, setCookies] = useState([
    { key: 'session_user', val: 'alice_dev', type: 'cookie' },
    { key: 'is_admin', val: 'true', type: 'cookie' },
    { key: 'theme', val: 'system', type: 'localStorage' },
  ])
  const [editingKey, setEditingKey] = useState<string | null>(null)
  const [editValue, setEditValue] = useState('')

  const handleEditClick = (key: string, currentVal: string) => {
    setEditingKey(key)
    setEditValue(currentVal)
  }

  const handleSaveCookie = (key: string) => {
    setCookies(prev => prev.map(c => c.key === key ? { ...c, val: editValue } : c))
    setEditingKey(null)
  }

  const handleDeleteCookie = (key: string) => {
    setCookies(prev => prev.filter(c => c.key !== key))
  }

  // Derived user status from cookie state
  const sessionUser = cookies.find(c => c.key === 'session_user')?.val
  const isAdmin = cookies.find(c => c.key === 'is_admin')?.val === 'true'

  let sessionStatus = 'Session Expired'
  let sessionColor = 'text-rose-400 bg-rose-500/10 border-rose-500/20'
  if (sessionUser) {
    if (isAdmin) {
      sessionStatus = `Admin: ${sessionUser}`
      sessionColor = 'text-emerald-400 bg-emerald-500/10 border-emerald-500/20'
    } else {
      sessionStatus = `User: ${sessionUser}`
      sessionColor = 'text-amber-400 bg-amber-500/10 border-amber-500/20'
    }
  }

  // --- PRIVACY SHIELD STATE ---
  const [httpsEnabled, setHttpsEnabled] = useState(true)
  const [blockedCount, setBlockedCount] = useState(847)
  const [triggeringTrackers, setTriggeringTrackers] = useState(false)

  const handleTriggerTrackers = () => {
    setBlockedCount(prev => prev + 3)
    setTriggeringTrackers(true)
    setTimeout(() => setTriggeringTrackers(false), 300)
  }

  if (type === 'ai') {
    return (
      <div className="h-full flex flex-col p-4 text-white">
        <div className="flex items-center gap-2 mb-3 pb-2.5 border-b border-white/[0.06]">
          <div className="w-6 h-6 rounded-full bg-orange-500/15 border border-orange-500/30 flex items-center justify-center">
            <Sparkles size={11} className="text-orange-400" />
          </div>
          <div>
            <div className="text-[12px] font-semibold">Local AI Assistant</div>
            <div className="text-[9px] text-zinc-500">Ollama / LM Studio Bridge</div>
          </div>
          <div className="ml-auto flex items-center gap-2">
            <span className="text-[9px] text-zinc-400 font-mono">Reasoning:</span>
            <div className="flex rounded border border-white/10 overflow-hidden text-[9px] font-mono">
              {(['low', 'med', 'high'] as const).map(level => (
                <button
                  key={level}
                  onClick={() => setReasoning(level)}
                  className={`px-1.5 py-0.5 capitalize cursor-pointer transition-colors ${
                    reasoning === level ? 'bg-orange-600 text-white' : 'bg-white/5 text-zinc-400 hover:text-white'
                  }`}
                >
                  {level}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Message Panel */}
        <div className="flex-1 overflow-y-auto space-y-2.5 min-h-0 pr-1 select-none scrollbar-thin">
          <AnimatePresence initial={false}>
            {aiMessages.map((msg, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                className={`flex gap-2 ${msg.role === 'ai' ? 'justify-end' : ''}`}
              >
                {msg.role === 'user' && (
                  <div className="w-5 h-5 rounded-full bg-white/10 flex-shrink-0 mt-0.5 flex items-center justify-center text-[9px] text-zinc-300">U</div>
                )}
                <div className={`max-w-[85%] px-3 py-2 text-[11px] leading-relaxed rounded-xl ${
                  msg.role === 'ai'
                    ? 'bg-orange-500/[0.06] text-zinc-300 rounded-tr-sm border border-orange-500/10'
                    : 'bg-white/[0.04] text-zinc-300 rounded-tl-sm'
                }`}>
                  {msg.text}
                </div>
              </motion.div>
            ))}
            {aiTyping && (
              <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="flex justify-end">
                <div className="bg-orange-500/[0.06] rounded-xl rounded-tr-sm px-3 py-2 border border-orange-500/10 flex items-center gap-2">
                  <div className="flex gap-0.5">
                    <span className="w-1 h-1 rounded-full bg-zinc-400 animate-bounce" style={{ animationDelay: '0ms' }} />
                    <span className="w-1 h-1 rounded-full bg-zinc-400 animate-bounce" style={{ animationDelay: '150ms' }} />
                    <span className="w-1 h-1 rounded-full bg-zinc-400 animate-bounce" style={{ animationDelay: '300ms' }} />
                  </div>
                  <span className="text-[9px] font-mono text-zinc-500">
                    {reasoning === 'high' ? 'thinking (42t/s)...' : 'local...'}
                  </span>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* Input */}
        <div className="mt-2.5 pt-2 border-t border-white/[0.06] flex items-center gap-2">
          <input
            value={aiInput}
            onChange={e => setAiInput(e.target.value)}
            onKeyDown={e => e.key === 'Enter' && handleAiSend()}
            placeholder="Summarize this... (try typing 'privacy' or 'tabs')"
            className="flex-1 bg-white/[0.03] border border-white/10 rounded-lg px-2.5 py-1.5 text-[11px] text-zinc-200 placeholder:text-zinc-600 outline-none focus:border-orange-500/40 transition-colors"
          />
          <button
            onClick={handleAiSend}
            className="w-8 h-8 rounded-lg bg-orange-600 hover:bg-orange-700 flex items-center justify-center text-white transition-colors cursor-pointer active:scale-95"
          >
            <Send size={11} />
          </button>
        </div>
      </div>
    )
  }

  if (type === 'dev') {
    return (
      <div className="h-full flex flex-col p-4 text-white select-none">
        <div className="flex items-center justify-between mb-3 pb-2.5 border-b border-white/[0.06]">
          <div>
            <div className="text-[12px] font-semibold flex items-center gap-1">
              <Code2 size={13} className="text-orange-500" />
              <span>Cookie & LocalStorage Editor</span>
            </div>
            <div className="text-[9px] text-zinc-500">Native Tab Isolated Storage</div>
          </div>
          <span className={`text-[9.5px] font-mono px-2 py-0.5 rounded border transition-all duration-300 ${sessionColor}`}>
            {sessionStatus}
          </span>
        </div>

        {/* Cookie list */}
        <div className="flex-1 overflow-y-auto space-y-1.5 min-h-0 pr-1 scrollbar-thin">
          <div className="grid grid-cols-[1fr_1.2fr_0.8fr] gap-2 px-2 py-1 text-[9.5px] font-mono font-semibold text-zinc-500 uppercase">
            <span>Key</span>
            <span>Value</span>
            <span className="text-right">Actions</span>
          </div>
          <div className="space-y-1.5 divide-y divide-white/[0.03] text-[10.5px] font-mono">
            {cookies.map(cookie => (
              <div key={cookie.key} className="grid grid-cols-[1fr_1.2fr_0.8fr] gap-2 px-2 pt-1.5 items-center text-zinc-300">
                <span className="truncate text-zinc-400 font-semibold" title={cookie.key}>{cookie.key}</span>
                {editingKey === cookie.key ? (
                  <input
                    value={editValue}
                    onChange={e => setEditValue(e.target.value)}
                    onBlur={() => handleSaveCookie(cookie.key)}
                    onKeyDown={e => e.key === 'Enter' && handleSaveCookie(cookie.key)}
                    autoFocus
                    className="bg-zinc-800 border border-orange-500/40 rounded px-1 text-[10.5px] text-zinc-100 outline-none w-full"
                  />
                ) : (
                  <span
                    onClick={() => handleEditClick(cookie.key, cookie.val)}
                    className="truncate hover:underline cursor-pointer text-emerald-400 hover:text-emerald-300 font-medium"
                    title={cookie.val}
                  >
                    {cookie.val}
                  </span>
                )}
                <div className="flex items-center justify-end gap-2 text-right">
                  <button
                    onClick={() => handleEditClick(cookie.key, cookie.val)}
                    className="text-zinc-500 hover:text-orange-400 p-0.5 cursor-pointer"
                    title="Edit Row"
                  >
                    <Edit2 size={10} />
                  </button>
                  <button
                    onClick={() => handleDeleteCookie(cookie.key)}
                    className="text-zinc-500 hover:text-rose-400 p-0.5 cursor-pointer"
                    title="Delete Row"
                  >
                    <Trash2 size={10} />
                  </button>
                </div>
              </div>
            ))}
            {cookies.length === 0 && (
              <div className="text-center py-6 text-zinc-600 text-[11px] font-sans">
                Storage is empty. Set credentials to restore session.
              </div>
            )}
          </div>
        </div>

        <div className="mt-3 pt-2.5 border-t border-white/[0.06] flex items-center justify-between text-[9px] text-zinc-500">
          <span>Click a value to quick-edit. Changes update user state mock.</span>
          {cookies.length < 3 && (
            <button
              onClick={() => setCookies([
                { key: 'session_user', val: 'alice_dev', type: 'cookie' },
                { key: 'is_admin', val: 'true', type: 'cookie' },
                { key: 'theme', val: 'system', type: 'localStorage' },
              ])}
              className="text-orange-500 hover:underline cursor-pointer"
            >
              Reset Cookies
            </button>
          )}
        </div>
      </div>
    )
  }

  // --- PRIVACY SHIELD PREVIEW ---
  return (
    <div className="h-full flex flex-col p-4 text-white select-none">
      <div className="flex items-center justify-between mb-3 pb-2.5 border-b border-white/[0.06]">
        <div>
          <div className="text-[12px] font-semibold flex items-center gap-1.5">
            <ShieldCheck size={14} className="text-emerald-400" />
            <span>Active Privacy Shield</span>
          </div>
          <div className="text-[9px] text-zinc-500">On-device active filtration</div>
        </div>
        <button
          onClick={handleTriggerTrackers}
          className={`text-[9.5px] font-mono px-2 py-0.5 rounded border border-orange-500/25 bg-orange-600/10 text-orange-400 hover:bg-orange-600/20 active:scale-95 transition-all duration-300 cursor-pointer ${
            triggeringTrackers ? 'scale-[1.05]' : ''
          }`}
        >
          {triggeringTrackers ? 'Tracking Blocked!' : 'Test Tracker Block'}
        </button>
      </div>

      {/* Grid status */}
      <div className="grid grid-cols-2 gap-2.5 flex-1 min-h-0 items-stretch">
        <div className="bg-white/[0.02] border border-white/[0.04] rounded-xl p-3 flex flex-col justify-between">
          <div className="text-[10px] text-zinc-500 font-mono uppercase tracking-tight">HTTPS Upgrade Engine</div>
          <div className="flex items-center justify-between gap-1 mt-1">
            <span className="text-[11.5px] font-semibold text-zinc-200">HTTPS-Only Mode</span>
            <button
              onClick={() => setHttpsEnabled(!httpsEnabled)}
              className={`w-7 h-4 rounded-full p-0.5 transition-colors cursor-pointer ${httpsEnabled ? 'bg-emerald-600' : 'bg-zinc-700'}`}
            >
              <div className={`w-3 h-3 rounded-full bg-white transition-transform ${httpsEnabled ? 'translate-x-3' : 'translate-x-0'}`} />
            </button>
          </div>
          <div className="mt-2.5 py-1 px-1.5 rounded bg-[#100f0d] border border-white/[0.04] font-mono text-[9px] text-zinc-400 flex items-center gap-1.5">
            {httpsEnabled ? (
              <>
                <Check size={9} className="text-emerald-400" />
                <span className="text-emerald-400">https://</span>
                <span className="truncate">docs.soul.dev</span>
              </>
            ) : (
              <>
                <AlertTriangle size={9} className="text-rose-400" />
                <span className="text-rose-400">http://</span>
                <span className="truncate">docs.soul.dev</span>
              </>
            )}
          </div>
        </div>

        <div className="bg-white/[0.02] border border-white/[0.04] rounded-xl p-3 flex flex-col justify-between">
          <div className="text-[10px] text-zinc-500 font-mono uppercase tracking-tight">Blocked Analytics</div>
          <div className="mt-1">
            <div className="text-2xl font-bold text-orange-400 tabular-nums">{blockedCount}</div>
            <div className="text-[9px] text-zinc-400 mt-0.5">Trackers and scripts filtered</div>
          </div>
          <div className="mt-2 text-[9px] text-zinc-500 font-mono flex items-center gap-1">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-400" />
            <span>Layer-0 filter: active</span>
          </div>
        </div>
      </div>

      {/* Fingerprinting block */}
      <div className="mt-3 p-2.5 rounded-xl bg-white/[0.03] border border-white/[0.05] space-y-1.5">
        <div className="text-[9.5px] font-mono text-zinc-400 uppercase tracking-tight flex items-center gap-1">
          <Shield size={10} className="text-orange-500" />
          <span>Fingerprint Randomization Details</span>
        </div>
        <div className="grid grid-cols-[1.2fr_1.8fr] gap-x-2 gap-y-0.5 text-[9.5px] font-mono">
          <span className="text-zinc-500">WebGL Renderer:</span>
          <span className="text-zinc-300 truncate font-semibold">Apple GPU (Apple Inc.)</span>
          <span className="text-zinc-500">Canvas Entropy:</span>
          <span className="text-orange-400 truncate">Noise added (+1px jitter)</span>
          <span className="text-zinc-500">Screen Size:</span>
          <span className="text-zinc-300">Rounded to nearest 10px</span>
        </div>
      </div>
    </div>
  )
}

export default function Showcase() {
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true, margin: '-80px' })
  const [activeTab, setActiveTab] = useState('ai')

  useEffect(() => {
    const handleSetTab = (e: Event) => {
      const customEvent = e as CustomEvent<string>
      if (customEvent.detail) {
        setActiveTab(customEvent.detail)
      }
    }
    window.addEventListener('soul-set-showcase-tab', handleSetTab)
    return () => window.removeEventListener('soul-set-showcase-tab', handleSetTab)
  }, [])

  const active = tabs.find((t) => t.id === activeTab)!

  return (
    <section id="showcase" className="py-24 md:py-32 relative">
      <div className="max-w-5xl mx-auto px-6">
        <motion.div
          ref={ref}
          initial={{ opacity: 0, y: 24 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="text-center mb-14"
        >
          <h2 className="font-display font-semibold text-4xl md:text-5xl tracking-[-0.03em] leading-[1.02] text-zinc-900 dark:text-zinc-100 mb-4 text-balance transition-colors">
            Three <span className="text-orange-600">Pillars</span> of Soul
          </h2>
          <p className="text-base text-zinc-600 dark:text-zinc-400 max-w-lg mx-auto leading-[1.6]">
            Try our interactive feature simulations below. Experience Soul\'s developer utilities and local AI right from the page.
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
            <div className="flex gap-1.5 p-1 rounded-xl bg-zinc-900/[0.04] dark:bg-zinc-50/[0.04] border border-zinc-900/10 dark:border-white/10">
              {tabs.map((tab) => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex-1 flex items-center justify-center gap-2 px-4 py-2.5 rounded-lg text-[13px] font-medium transition-all duration-300 active:scale-[0.98] focus:outline-none cursor-pointer ${
                    activeTab === tab.id
                      ? 'bg-white dark:bg-[#1a1916] text-[#14130f] dark:text-[#f5f3ee] shadow-[0_2px_8px_-4px_rgba(20,19,15,0.25)] dark:shadow-[0_2px_8px_-4px_rgba(0,0,0,0.5)] border border-zinc-950/5 dark:border-white/5'
                      : 'text-zinc-500 dark:text-zinc-400 hover:text-zinc-800 dark:hover:text-zinc-200'
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
                className="space-y-4 text-zinc-850 dark:text-zinc-200"
              >
                <h3 className="font-display text-xl font-semibold text-zinc-900 dark:text-zinc-100">{active.title}</h3>
                <p className="text-[13px] text-zinc-650 dark:text-zinc-400 leading-[1.7]">{active.description}</p>
                <ul className="space-y-2 pt-1 font-medium">
                  {active.highlights.map((h) => (
                    <li key={h} className="flex items-center gap-2.5 text-[12px] text-zinc-600 dark:text-zinc-400">
                      <div className="w-[4px] h-[4px] rounded-full bg-orange-650 dark:bg-orange-500 flex-shrink-0" />
                      <span>{h}</span>
                    </li>
                  ))}
                </ul>
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Right: Preview - Native macOS Window Mockup */}
          <div className="relative">
            <div className="relative rounded-2xl border border-zinc-900/10 dark:border-white/10 bg-white dark:bg-[#0c0b09] overflow-hidden shadow-[0_30px_60px_-24px_rgba(20,19,15,0.4)] dark:shadow-[0_30px_60px_-24px_rgba(0,0,0,0.6)] h-[400px] flex transition-colors duration-300">
              
              {/* Left: Main Web View Area */}
              <div className="flex-1 flex flex-col bg-[#f8f7f4] dark:bg-[#12110e] transition-colors">
                {/* Unified Titlebar */}
                <div className="h-10 flex items-center px-4 border-b border-black/5 dark:border-white/5 gap-3 shrink-0">
                  <div className="flex gap-1.5 opacity-80">
                    <div className="w-3 h-3 rounded-full bg-[#ff5f56] border border-black/10 dark:border-transparent" />
                    <div className="w-3 h-3 rounded-full bg-[#ffbd2e] border border-black/10 dark:border-transparent" />
                    <div className="w-3 h-3 rounded-full bg-[#27c93f] border border-black/10 dark:border-transparent" />
                  </div>
                  <div className="flex-1 flex justify-center">
                    <div className="px-3 py-1 bg-black/5 dark:bg-white/5 rounded-md text-[10px] font-medium text-zinc-500 font-mono shadow-inner">
                      https://github.com/soulcloude00
                    </div>
                  </div>
                  <div className="w-12" /> {/* Spacer for centering */}
                </div>
                
                {/* Fake Web Content */}
                <div className="flex-1 p-6 relative overflow-hidden">
                  <div className="w-3/4 h-6 bg-zinc-200 dark:bg-white/10 rounded-lg mb-4" />
                  <div className="w-full h-3 bg-zinc-100 dark:bg-white/5 rounded mb-2" />
                  <div className="w-5/6 h-3 bg-zinc-100 dark:bg-white/5 rounded mb-2" />
                  <div className="w-full h-3 bg-zinc-100 dark:bg-white/5 rounded mb-6" />
                  
                  <div className="grid grid-cols-2 gap-4">
                    <div className="h-24 bg-zinc-100 dark:bg-white/5 rounded-xl border border-black/5 dark:border-white/5" />
                    <div className="h-24 bg-zinc-100 dark:bg-white/5 rounded-xl border border-black/5 dark:border-white/5" />
                  </div>
                  
                  {/* Subtle fade out at bottom */}
                  <div className="absolute bottom-0 left-0 right-0 h-16 bg-gradient-to-t from-[#f8f7f4] dark:from-[#12110e] to-transparent pointer-events-none" />
                </div>
              </div>

              {/* Right: Spatial Sidebar (Liquid Glass) */}
              <div className="w-[280px] border-l border-black/10 dark:border-white/10 bg-white/70 dark:bg-black/40 backdrop-blur-2xl flex flex-col transition-colors z-10 shrink-0">
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
          </div>
        </motion.div>
      </div>
    </section>
  )
}
