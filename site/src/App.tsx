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
    <div className="min-h-screen bg-[#0a0a0f] text-slate-200 overflow-x-hidden relative selection:bg-orange-500/25 selection:text-white">
      {/* Minimalist ambient background */}
      <div className="fixed inset-0 pointer-events-none z-0">
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[600px] h-[500px] bg-orange-500/[0.025] blur-[100px] rounded-full" />
        <div className="absolute inset-0 dots opacity-30" />
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
