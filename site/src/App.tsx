import Nav from './components/Nav'
import Hero from './components/Hero'
import Marquee from './components/Marquee'
import Features from './components/Features'
import Engine from './components/Engine'
import Showcase from './components/Showcase'
import Stats from './components/Stats'
import CTA from './components/CTA'
import Footer from './components/Footer'

export default function App() {
  return (
    <div className="grain relative min-h-screen bg-void text-bone overflow-x-hidden">
      {/* Ambient structural grid, fading below the fold */}
      <div className="fixed inset-0 pointer-events-none z-0">
        <div className="absolute inset-0 grid-faint opacity-50 [mask-image:linear-gradient(to_bottom,black,transparent_60%)]" />
      </div>

      <div className="relative z-10">
        <Nav />
        <main>
          <Hero />
          <Marquee />
          <Features />
          <Engine />
          <Showcase />
          <Stats />
          <CTA />
        </main>
        <Footer />
      </div>
    </div>
  )
}
