import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Menu, X, Github, Search, Command } from 'lucide-react'

const links = [
  { label: 'Features', href: '#features' },
  { label: 'Architecture', href: '#architecture' },
  { label: 'Showcase', href: '#showcase' },
  { label: 'Roadmap', href: '#roadmap' },
]

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false)
  const [menuOpen, setMenuOpen] = useState(false)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20)
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  return (
    <motion.header
      initial={{ y: -20, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.5, ease: [0.22, 1, 0.36, 1] }}
      className="fixed top-0 left-0 right-0 z-50"
    >
      <div className={`mx-auto mt-3 max-w-5xl px-4 transition-all duration-500 ${scrolled ? '' : ''}`}>
        <div className={`flex items-center justify-between px-5 py-2.5 rounded-2xl transition-all duration-500 ${
          scrolled ? 'glass-strong shadow-[0_6px_24px_-12px_rgba(20,19,15,0.25)]' : 'bg-transparent border border-transparent'
        }`}>
          <a href="#" className="flex items-center gap-2.5 group">
            <div className="w-7 h-7 rounded-md bg-[#14130f] flex items-center justify-center">
              <svg width="14" height="14" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M11 19.5858L15 23.5858V29H7V23.5858L11 19.5858Z" fill="#fb923c"/>
                <path d="M21.4142 10H10.5858L2 18.5858V30H30V18.5858L21.4142 10ZM11 12.4142L4 19.4142V28H18V19.4142L11 12.4142Z" fill="#fb923c" opacity="0.5"/>
                <path d="M7 2C4.23858 2 2 4.23858 2 7C2 9.37733 3.65914 11.3671 5.88267 11.8747L9.17157 8.58579C9.54665 8.21071 10.0554 8 10.5858 8H11.9C11.9656 7.67689 12 7.34247 12 7C12 4.23858 9.76142 2 7 2Z" fill="#fb923c" opacity="0.7"/>
              </svg>
            </div>
            <span className="font-display font-semibold text-[16px] tracking-tight text-[#14130f]">Soul</span>
          </a>

          <nav className="hidden md:flex items-center">
            {links.map((link) => (
              <a
                key={link.href}
                href={link.href}
                className="px-4 py-1.5 text-sm text-zinc-600 hover:text-[#14130f] transition-colors duration-300 active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-zinc-900/10 rounded-lg"
              >
                {link.label}
              </a>
            ))}
          </nav>

          <div className="hidden md:flex items-center gap-2">
            <button
              onClick={() => {
                const evt = new KeyboardEvent('keydown', { metaKey: true, key: 'k' })
                window.dispatchEvent(evt)
              }}
              className="flex items-center gap-1.5 px-2.5 py-1.5 text-xs text-zinc-500 hover:text-[#14130f] transition-colors duration-300 rounded-lg hover:bg-zinc-900/[0.04] active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-zinc-900/10"
            >
              <Search size={13} />
              <span className="hidden lg:inline">Search</span>
              <kbd className="hidden lg:flex items-center gap-0.5 px-1 py-0.5 rounded bg-zinc-900/[0.05] border border-zinc-900/10 text-[10px] text-zinc-500 font-mono ml-1">
                <Command size={9} />K
              </kbd>
            </button>
            <a
              href="https://github.com/soulcloude/mori-browser"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-1.5 px-2.5 py-1.5 text-sm text-zinc-500 hover:text-[#14130f] transition-colors duration-300 rounded-lg hover:bg-zinc-900/[0.04] active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-zinc-900/10"
            >
              <Github size={14} />
            </a>
            <a
              href="#"
              className="px-4 py-1.5 text-sm font-medium bg-[#14130f] hover:bg-[#2a2822] text-[#f5f3ee] rounded-lg transition-all duration-300 active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-zinc-900/20 focus:ring-offset-2 focus:ring-offset-[#ece9e2]"
            >
              Download
            </a>
          </div>

          <button
            onClick={() => setMenuOpen(!menuOpen)}
            className="md:hidden p-1.5 text-zinc-600 hover:text-[#14130f] active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-zinc-900/10 rounded-lg"
          >
            {menuOpen ? <X size={18} /> : <Menu size={18} />}
          </button>
        </div>
      </div>

      <AnimatePresence>
        {menuOpen && (
          <motion.div
            initial={{ opacity: 0, y: -8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            transition={{ duration: 0.2 }}
            className="md:hidden mx-4 mt-2 glass-strong rounded-2xl overflow-hidden shadow-[0_12px_32px_-16px_rgba(20,19,15,0.3)]"
          >
            <div className="px-3 py-3 flex flex-col gap-0.5">
              {links.map((link) => (
                <a
                  key={link.href}
                  href={link.href}
                  onClick={() => setMenuOpen(false)}
                  className="px-4 py-2.5 text-sm text-zinc-700 hover:text-[#14130f] hover:bg-zinc-900/[0.04] rounded-xl transition-colors active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-zinc-900/10"
                >
                  {link.label}
                </a>
              ))}
              <div className="mt-2 pt-2 border-t border-zinc-900/10 flex flex-col gap-1">
                <a
                  href="https://github.com/soulcloude/mori-browser"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-2 px-4 py-2.5 text-sm text-zinc-600 hover:text-[#14130f] active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-zinc-900/10 rounded-xl"
                >
                  <Github size={14} />
                  <span>GitHub</span>
                </a>
                <a
                  href="#"
                  className="mx-1 px-4 py-2.5 text-center text-sm font-medium bg-[#14130f] text-[#f5f3ee] rounded-xl active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-zinc-900/20"
                >
                  Download
                </a>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.header>
  )
}
