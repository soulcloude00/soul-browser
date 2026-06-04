import Navbar from './components/Navbar'
import Hero from './components/Hero'
import Features from './components/Features'
import Architecture from './components/Architecture'
import Showcase from './components/Showcase'
import Roadmap from './components/Roadmap'
import Footer from './components/Footer'

export default function App() {
  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 overflow-x-hidden">
      <div className="fixed inset-0 bg-[radial-gradient(ellipse_80%_50%_at_50%_-20%,rgba(254,128,16,0.08),transparent)] pointer-events-none" />
      <div className="fixed inset-0 bg-[radial-gradient(circle_at_80%_40%,rgba(254,128,16,0.04),transparent_50%)] pointer-events-none" />
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
  )
}
