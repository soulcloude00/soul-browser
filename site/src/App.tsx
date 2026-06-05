import Navbar from './components/Navbar'
import Hero from './components/Hero'
import Features from './components/Features'
import Architecture from './components/Architecture'
import Showcase from './components/Showcase'
import Roadmap from './components/Roadmap'
import Footer from './components/Footer'
import CommandPalette from './components/CommandPalette'

export default function App() {
  return (
    <div className="min-h-screen bg-[#09090c] text-slate-300 overflow-x-hidden relative selection:bg-orange-500/25 selection:text-white">
      {/* Ambient background: single warm wash + faint structural grid fading toward the fold */}
      <div className="fixed inset-0 pointer-events-none z-0">
        <div className="absolute -top-40 left-1/2 -translate-x-1/2 w-[900px] h-[600px] bg-orange-600/[0.05] blur-[120px] rounded-full" />
        <div className="absolute inset-0 grid-lines [mask-image:linear-gradient(to_bottom,black,transparent_85%)] opacity-60" />
      </div>

      <div className="relative z-10">
        <Navbar />
        <main>
          <Hero />
          <Features />
          <Architecture />
          <Showcase />
          <Roadmap />
        </main>
        <Footer />
      </div>

      <CommandPalette />
    </div>
  )
}
