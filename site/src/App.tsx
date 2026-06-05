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
    <div className="min-h-screen bg-[#ece9e2] text-[#14130f] overflow-x-hidden relative">
      {/* Ambient: faint structural Swiss grid fading toward the fold */}
      <div className="fixed inset-0 pointer-events-none z-0">
        <div className="absolute inset-0 grid-lines [mask-image:linear-gradient(to_bottom,black,transparent_70%)] opacity-70" />
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
