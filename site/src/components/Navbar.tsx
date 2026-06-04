import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Menu, X, Github } from 'lucide-react'

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
    const onScroll = () => setScrolled(window.scrollY > 40)
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  return (
    <motion.header
      initial={{ y: -40, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.6, ease: 'easeOut' }}
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        scrolled ? 'glass-strong' : 'bg-transparent'
      }`}
    >
      <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
        <a href="#" className="flex items-center gap-2.5 group">
          <div className="w-8 h-8 rounded-lg bg-accent-500/10 border border-accent-500/20 flex items-center justify-center group-hover:bg-accent-500/20 transition-colors">
            <svg width="18" height="18" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M11 19.5858L15 23.5858V29H7V23.5858L11 19.5858Z" fill="#fe8010"/>
              <path d="M21.4142 10H10.5858L2 18.5858V30H30V18.5858L21.4142 10ZM11 12.4142L4 19.4142V28H18V19.4142L11 12.4142Z" fill="#fe8010" opacity="0.6"/>
              <path d="M7 2C4.23858 2 2 4.23858 2 7C2 9.37733 3.65914 11.3671 5.88267 11.8747L9.17157 8.58579C9.54665 8.21071 10.0554 8 10.5858 8H11.9C11.9656 7.67689 12 7.34247 12 7C12 4.23858 9.76142 2 7 2Z" fill="#fe8010" opacity="0.8"/>
            </svg>
          </div>
          <span className="font-semibold text-lg tracking-tight">Soul</span>
        </a>

        <nav className="hidden md:flex items-center gap-1">
          {links.map((link) => (
            <a
              key={link.href}
              href={link.href}
              className="px-4 py-2 text-sm text-slate-400 hover:text-white transition-colors rounded-lg hover:bg-white/5"
            >
              {link.label}
            </a>
          ))}
        </nav>

        <div className="hidden md:flex items-center gap-3">
          <a
            href="https://github.com/soulcloude/mori-browser"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-2 px-4 py-2 text-sm text-slate-400 hover:text-white transition-colors"
          >
            <Github size={16} />
            <span>GitHub</span>
          </a>
          <a
            href="#"
            className="px-4 py-2 text-sm font-medium bg-accent-500 hover:bg-accent-400 text-white rounded-lg transition-colors glow-amber-sm"
          >
            Download
          </a>
        </div>

        <button
          onClick={() => setMenuOpen(!menuOpen)}
          className="md:hidden p-2 text-slate-400 hover:text-white"
        >
          {menuOpen ? <X size={20} /> : <Menu size={20} />}
        </button>
      </div>

      <AnimatePresence>
        {menuOpen && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            className="md:hidden glass-strong border-t border-white/5 overflow-hidden"
          >
            <div className="px-6 py-4 flex flex-col gap-1">
              {links.map((link) => (
                <a
                  key={link.href}
                  href={link.href}
                  onClick={() => setMenuOpen(false)}
                  className="px-4 py-3 text-slate-300 hover:text-white hover:bg-white/5 rounded-lg transition-colors"
                >
                  {link.label}
                </a>
              ))}
              <div className="mt-2 pt-2 border-t border-white/5 flex flex-col gap-2">
                <a
                  href="https://github.com/soulcloude/mori-browser"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-2 px-4 py-3 text-slate-400 hover:text-white"
                >
                  <Github size={16} />
                  <span>GitHub</span>
                </a>
                <a
                  href="#"
                  className="px-4 py-3 text-center font-medium bg-accent-500 hover:bg-accent-400 text-white rounded-lg transition-colors"
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
