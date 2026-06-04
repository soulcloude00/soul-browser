import Navbar from './components/Navbar'
import Hero from './components/Hero'
import Features from './components/Features'
import Architecture from './components/Architecture'
import Showcase from './components/Showcase'
import Roadmap from './components/Roadmap'
import Footer from './components/Footer'

export default function App() {
  return (
    <div className="min-h-screen bg-[#0a0a0f] text-slate-200 overflow-x-hidden relative selection:bg-orange-500/30 selection:text-white">
      {/* Premium ambient background layers */}
      <div className="fixed inset-0 pointer-events-none z-0">
        {/* Top amber glow */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[600px] bg-orange-500/[0.04] blur-[120px] rounded-full" />
        {/* Purple accent glow */}
        <div className="absolute top-[30%] right-0 w-[500px] h-[500px] bg-violet-500/[0.03] blur-[100px] rounded-full" />
        {/* Blue subtle glow */}
        <div className="absolute bottom-[20%] left-0 w-[400px] h-[400px] bg-blue-500/[0.02] blur-[80px] rounded-full" />
        {/* Grid pattern */}
        <div className="absolute inset-0 dots opacity-50" />
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
    </div>
  )
}
