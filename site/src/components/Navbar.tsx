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
          scrolled ? 'glass-strong' : 'bg-white/[0.02] border border-white/[0.04]'
        }`}>
          <a href="#" className="flex items-center gap-2.5 group">
            <div className="w-7 h-7 rounded-md bg-gradient-to-br from-orange-400/20 to-orange-600/10 border border-orange-500/20 flex items-center justify-center">
              <svg width="14" height="14" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M11 19.5858L15 23.5858V29H7V23.5858L11 19.5858Z" fill="#fb923c"/>
                <path d="M21.4142 10H10.5858L2 18.5858V30H30V18.5858L21.4142 10ZM11 12.4142L4 19.4142V28H18V19.4142L11 12.4142Z" fill="#fb923c" opacity="0.5"/>
                <path d="M7 2C4.23858 2 2 4.23858 2 7C2 9.37733 3.65914 11.3671 5.88267 11.8747L9.17157 8.58579C9.54665 8.21071 10.0554 8 10.5858 8H11.9C11.9656 7.67689 12 7.34247 12 7C12 4.23858 9.76142 2 7 2Z" fill="#fb923c" opacity="0.7"/>
              </svg>
            </div>
            <span className="font-semibold text-[15px] tracking-tight text-white/90">Soul</span>
          </a>

          <nav className="hidden md:flex items-center">
            {links.map((link) => (
              <a
                key={link.href}
                href={link.href}
                className="px-4 py-1.5 text-[13px] text-slate-400 hover:text-white transition-colors duration-300"
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
              className="flex items-center gap-1.5 px-2.5 py-1.5 text-[12px] text-slate-500 hover:text-slate-300 transition-colors duration-300 rounded-lg hover:bg-white/[0.03]"
            >
              <Search size={13} />
              <span className="hidden lg:inline">Search</span>
              <kbd className="hidden lg:flex items-center gap-0.5 px-1 py-0.5 rounded bg-white/[0.04] border border-white/[0.06] text-[10px] text-slate-600 font-mono ml-1">
                <Command size={9} />K
              </kbd>
            </button>
            <a
              href="https://github.com/soulcloude/mori-browser"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-1.5 px-2.5 py-1.5 text-[13px] text-slate-400 hover:text-white transition-colors duration-300 rounded-lg hover:bg-white/[0.03]"
            >
              <Github size={14} />
            </a>
            <a
              href="#"
              className="px-4 py-1.5 text-[13px] font-medium bg-white/90 hover:bg-white text-black rounded-lg transition-all duration-300"
            >
              Download
            </a>
          </div>

          <button
            onClick={() => setMenuOpen(!menuOpen)}
            className="md:hidden p-1.5 text-slate-400 hover:text-white"
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
            className="md:hidden mx-4 mt-2 glass-strong rounded-2xl border border-white/5 overflow-hidden"
          >
            <div className="px-3 py-3 flex flex-col gap-0.5">
              {links.map((link) => (
                <a
                  key={link.href}
                  href={link.href}
                  onClick={() => setMenuOpen(false)}
                  className="px-4 py-2.5 text-[13px] text-slate-300 hover:text-white hover:bg-white/5 rounded-xl transition-colors"
                >
                  {link.label}
                </a>
              ))}
              <div className="mt-2 pt-2 border-t border-white/5 flex flex-col gap-1">
                <a
                  href="https://github.com/soulcloude/mori-browser"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-2 px-4 py-2.5 text-[13px] text-slate-400 hover:text-white"
                >
                  <Github size={14} />
                  <span>GitHub</span>
                </a>
                <a
                  href="#"
                  className="mx-1 px-4 py-2.5 text-center text-[13px] font-medium bg-white/90 text-black rounded-xl"
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
