import { useState, useEffect, useRef, useCallback } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Search, ArrowRight, Command, FileText, Cpu, Shield, Code, Zap, Layout, Sun, Sparkles, BookOpen } from 'lucide-react'

const actions = [
  { id: 'theme', label: 'Toggle Theme', desc: 'Switch page between light and dark mode', icon: Sun, href: 'action:theme' },
  { id: 'ai_sim', label: 'Open Local AI Simulator', desc: 'Test on-device Codex panel responses', icon: Sparkles, href: 'action:ai_assistant' },
  { id: 'cookie_editor_sim', label: 'Open Cookie Editor Simulator', desc: 'View, edit, or delete cookies in the mockup', icon: Code, href: 'action:cookie_editor' },
  { id: 'privacy_shield_sim', label: 'Open Privacy Shield Simulator', desc: 'Toggle HTTPS-Only and see spoofing details', icon: Shield, href: 'action:privacy_shield' },
  { id: 'story_comp', label: 'The Browser Choice Story', desc: 'Narrative comparison of Chrome vs Safari vs Soul', icon: BookOpen, href: '#story-comparison' },
  { id: 'features', label: 'Features', desc: 'Browse all features', icon: Zap, href: '#features' },
  { id: 'architecture', label: 'Architecture', desc: 'System architecture overview', icon: Cpu, href: '#architecture' },
  { id: 'roadmap', label: 'Roadmap', desc: '106 features planned', icon: FileText, href: '#roadmap' },
  { id: 'tabs', label: 'Vertical Tabs', desc: 'Tab management system', icon: Layout, href: '#features' },
]

export default function CommandPalette() {
  const [open, setOpen] = useState(false)
  const [query, setQuery] = useState('')
  const [selected, setSelected] = useState(0)
  const inputRef = useRef<HTMLInputElement>(null)

  const filtered = query.trim()
    ? actions.filter(a =>
        a.label.toLowerCase().includes(query.toLowerCase()) ||
        a.desc.toLowerCase().includes(query.toLowerCase())
      )
    : actions

  const handleSelect = useCallback((action: typeof actions[0]) => {
    setOpen(false)
    setQuery('')
    setTimeout(() => {
      if (action.href.startsWith('action:')) {
        const cmd = action.href.split(':')[1]
        if (cmd === 'theme') {
          window.dispatchEvent(new Event('soul-toggle-theme'))
        } else if (cmd === 'cookie_editor') {
          const el = document.getElementById('showcase')
          if (el) el.scrollIntoView({ behavior: 'smooth' })
          window.dispatchEvent(new CustomEvent('soul-set-showcase-tab', { detail: 'dev' }))
        } else if (cmd === 'privacy_shield') {
          const el = document.getElementById('showcase')
          if (el) el.scrollIntoView({ behavior: 'smooth' })
          window.dispatchEvent(new CustomEvent('soul-set-showcase-tab', { detail: 'privacy' }))
        } else if (cmd === 'ai_assistant') {
          const el = document.getElementById('showcase')
          if (el) el.scrollIntoView({ behavior: 'smooth' })
          window.dispatchEvent(new CustomEvent('soul-set-showcase-tab', { detail: 'ai' }))
        }
      } else {
        const el = document.querySelector(action.href)
        if (el) el.scrollIntoView({ behavior: 'smooth' })
      }
    }, 150)
  }, [])

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault()
        setOpen(prev => !prev)
      }
      if (e.key === 'Escape') setOpen(false)
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [])

  useEffect(() => {
    if (open) {
      setTimeout(() => inputRef.current?.focus(), 50)
      setSelected(0)
    } else {
      setQuery('')
    }
  }, [open])

  useEffect(() => {
    setSelected(0)
  }, [query])

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (!open || filtered.length === 0) return
      if (e.key === 'ArrowDown') {
        e.preventDefault()
        setSelected(s => (s + 1) % filtered.length)
      }
      if (e.key === 'ArrowUp') {
        e.preventDefault()
        setSelected(s => (s - 1 + filtered.length) % filtered.length)
      }
      if (e.key === 'Enter') {
        e.preventDefault()
        if (filtered[selected]) handleSelect(filtered[selected])
      }
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [open, filtered, selected, handleSelect])

  return (
    <AnimatePresence>
      {open && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.15 }}
          className="fixed inset-0 z-[100] flex items-start justify-center pt-[20vh]"
          onClick={() => setOpen(false)}
        >
          <div className="absolute inset-0 bg-[#14130f]/40 dark:bg-black/60 backdrop-blur-sm transition-colors duration-300" />
          <motion.div
            initial={{ opacity: 0, y: -10, scale: 0.97 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -10, scale: 0.97 }}
            transition={{ duration: 0.2, ease: [0.22, 1, 0.36, 1] }}
            className="relative w-full max-w-lg mx-4 rounded-2xl border border-zinc-900/10 dark:border-white/10 bg-[#faf9f6] dark:bg-[#151412] shadow-[0_40px_80px_-24px_rgba(20,19,15,0.45)] dark:shadow-[0_40px_80px_-24px_rgba(0,0,0,0.6)] overflow-hidden transition-colors duration-300"
            onClick={e => e.stopPropagation()}
          >
            {/* Search input */}
            <div className="flex items-center gap-3 px-4 py-3.5 border-b border-zinc-900/10 dark:border-white/10 transition-colors">
              <Search size={16} className="text-zinc-500" />
              <input
                ref={inputRef}
                value={query}
                onChange={e => setQuery(e.target.value)}
                placeholder="Search actions, features, pages..."
                className="flex-1 bg-transparent text-[14px] text-[#14130f] dark:text-[#f5f3ee] placeholder:text-zinc-400 dark:placeholder:text-zinc-650 outline-none"
              />
              <kbd className="hidden sm:flex items-center gap-0.5 px-1.5 py-0.5 rounded-md bg-zinc-900/[0.05] dark:bg-white/[0.05] border border-zinc-900/10 dark:border-white/10 text-[10px] text-zinc-500 font-mono">
                <Command size={10} />K
              </kbd>
            </div>

            {/* Results */}
            <div className="max-h-[320px] overflow-y-auto py-2">
              {filtered.length === 0 ? (
                <div className="px-4 py-8 text-center text-[13px] text-zinc-500">
                  No results found for "{query}"
                </div>
              ) : (
                filtered.map((action, i) => (
                  <button
                    key={action.id}
                    onClick={() => handleSelect(action)}
                    onMouseEnter={() => setSelected(i)}
                    className={`w-full flex items-center gap-3 px-4 py-2.5 text-left transition-colors active:scale-[0.98] cursor-pointer ${
                      i === selected ? 'bg-zinc-900/[0.05] dark:bg-white/[0.05]' : 'hover:bg-zinc-900/[0.03] dark:hover:bg-white/[0.03]'
                    }`}
                  >
                    <div className={`w-7 h-7 rounded-lg flex items-center justify-center ${
                      i === selected ? 'bg-orange-600/10 text-orange-700 dark:text-orange-400' : 'bg-zinc-900/[0.05] dark:bg-white/[0.05] text-zinc-500 dark:text-zinc-400'
                    }`}>
                      <action.icon size={14} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="text-[13px] text-zinc-800 dark:text-zinc-200 font-medium">{action.label}</div>
                      <div className="text-[11px] text-zinc-550 dark:text-zinc-500">{action.desc}</div>
                    </div>
                    {i === selected && <ArrowRight size={14} className="text-zinc-500" />}
                  </button>
                ))
              )}
            </div>

            {/* Footer hint */}
            <div className="px-4 py-2 border-t border-zinc-900/10 dark:border-white/10 flex items-center gap-3 text-[10px] text-zinc-500 transition-colors">
              <span className="flex items-center gap-1">
                <kbd className="px-1 rounded bg-zinc-900/[0.05] dark:bg-white/[0.05] border border-zinc-900/10 dark:border-white/10 font-mono">↑↓</kbd>
                <span>Navigate</span>
              </span>
              <span className="flex items-center gap-1">
                <kbd className="px-1 rounded bg-zinc-900/[0.05] dark:bg-white/[0.05] border border-zinc-900/10 dark:border-white/10 font-mono">↵</kbd>
                <span>Select</span>
              </span>
              <span className="flex items-center gap-1 ml-auto">
                <kbd className="px-1 rounded bg-zinc-900/[0.05] dark:bg-white/[0.05] border border-zinc-900/10 dark:border-white/10 font-mono">esc</kbd>
                <span>Close</span>
              </span>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}
