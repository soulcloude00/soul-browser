import { useState, useEffect } from 'react'
import Navbar from './components/Navbar'
import Hero from './components/Hero'
import Features from './components/Features'
import Architecture from './components/Architecture'
import Showcase from './components/Showcase'
import StoryComparison from './components/StoryComparison'
import Roadmap from './components/Roadmap'
import Footer from './components/Footer'
import CommandPalette from './components/CommandPalette'

export default function App() {
  const [isDark, setIsDark] = useState(false)

  useEffect(() => {
    const saved = localStorage.getItem('theme')
    const dark = saved === 'dark' || (!saved && window.matchMedia('(prefers-color-scheme: dark)').matches)
    setIsDark(dark)
    if (dark) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  }, [])

  const toggleTheme = () => {
    setIsDark(prev => {
      const next = !prev
      localStorage.setItem('theme', next ? 'dark' : 'light')
      if (next) {
        document.documentElement.classList.add('dark')
      } else {
        document.documentElement.classList.remove('dark')
      }
      return next
    })
  }

  useEffect(() => {
    const handler = () => toggleTheme()
    window.addEventListener('soul-toggle-theme', handler)
    return () => window.removeEventListener('soul-toggle-theme', handler)
  }, [])

  return (
    <div className="min-h-screen bg-transparent text-current overflow-x-hidden relative">
      {/* Ambient: faint structural Swiss grid fading toward the fold */}
      <div className="fixed inset-0 pointer-events-none z-0">
        <div className="absolute inset-0 grid-lines [mask-image:linear-gradient(to_bottom,black,transparent_70%)] opacity-70" />
      </div>

      <div className="relative z-10">
        <Navbar isDark={isDark} onToggleTheme={toggleTheme} />
        <main>
          <Hero />
          <Features />
          <Architecture />
          <Showcase />
          <StoryComparison />
          <Roadmap />
        </main>
        <Footer />
      </div>

      <CommandPalette />
    </div>
  )
}
