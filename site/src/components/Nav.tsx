import { useEffect, useState } from 'react'
import { motion } from 'framer-motion'
import { ArrowUpRight } from 'lucide-react'

const links = [
  { label: 'Features', href: '#features' },
  { label: 'Engine', href: '#engine' },
  { label: 'Command', href: '#command' },
]

export default function Nav() {
  const [scrolled, setScrolled] = useState(false)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 24)
    onScroll()
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  return (
    <motion.header
      initial={{ y: -24, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.7, ease: [0.22, 1, 0.36, 1] }}
      className={`fixed top-0 inset-x-0 z-50 transition-all duration-500 ${
        scrolled
          ? 'bg-void/70 backdrop-blur-xl border-b hairline'
          : 'bg-transparent border-b border-transparent'
      }`}
    >
      <nav className="max-w-7xl mx-auto px-6 lg:px-10 h-[68px] flex items-center justify-between">
        <a href="#top" className="flex items-center gap-3 group">
          <img src="/soul.svg" alt="" className="w-7 h-7 group-hover:rotate-[20deg] transition-transform duration-500" />
          <span className="font-display font-semibold text-[17px] tracking-tight">soul</span>
          <span className="hidden sm:inline-block font-mono text-[10px] text-dim tracking-[0.2em] uppercase mt-[3px]">browser</span>
        </a>

        <div className="hidden md:flex items-center gap-8">
          {links.map((l) => (
            <a
              key={l.href}
              href={l.href}
              className="link-line text-[13px] text-ash hover:text-bone transition-colors duration-300"
            >
              {l.label}
            </a>
          ))}
        </div>

        <a
          href="https://github.com/soulcloude00/soul-browser"
          target="_blank"
          rel="noopener noreferrer"
          className="group inline-flex items-center gap-1.5 text-[13px] font-medium px-4 py-2 rounded-full border hairline-strong hover:border-ember hover:text-ember transition-colors duration-300"
        >
          GitHub
          <ArrowUpRight size={14} className="transition-transform duration-300 group-hover:translate-x-0.5 group-hover:-translate-y-0.5" />
        </a>
      </nav>
    </motion.header>
  )
}
