export default function Footer() {
  return (
    <footer className="border-t hairline relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-6 lg:px-10 pt-16 pb-10">
        <div className="flex flex-col md:flex-row md:items-start justify-between gap-10">
          <div className="flex items-center gap-3">
            <img src="/soul.svg" alt="Soul" className="w-8 h-8" />
            <div>
              <p className="font-display font-semibold tracking-tight">soul</p>
              <p className="text-[12px] text-dim">A browser with a soul. Built for macOS.</p>
            </div>
          </div>

          <div className="flex gap-16">
            <div>
              <p className="font-mono text-[10px] tracking-[0.28em] uppercase text-dim mb-4">Project</p>
              <ul className="space-y-2.5 text-[13px] text-ash">
                <li><a href="https://github.com/soulcloude00/soul-browser" target="_blank" rel="noopener noreferrer" className="link-line hover:text-bone transition-colors">GitHub</a></li>
                <li><a href="https://github.com/soulcloude00/soul-browser/blob/main/ROADMAP.md" target="_blank" rel="noopener noreferrer" className="link-line hover:text-bone transition-colors">Roadmap</a></li>
                <li><a href="https://github.com/soulcloude00/soul-browser/blob/main/CONTRIBUTING.md" target="_blank" rel="noopener noreferrer" className="link-line hover:text-bone transition-colors">Contributing</a></li>
              </ul>
            </div>
            <div>
              <p className="font-mono text-[10px] tracking-[0.28em] uppercase text-dim mb-4">Site</p>
              <ul className="space-y-2.5 text-[13px] text-ash">
                <li><a href="#features" className="link-line hover:text-bone transition-colors">Features</a></li>
                <li><a href="#engine" className="link-line hover:text-bone transition-colors">Engine</a></li>
                <li><a href="#command" className="link-line hover:text-bone transition-colors">Command</a></li>
              </ul>
            </div>
          </div>
        </div>

        <div className="mt-14 pt-8 border-t hairline flex flex-col sm:flex-row items-center justify-between gap-4 font-mono text-[11px] text-dim">
          <span>&copy; {new Date().getFullYear()} Soul Browser &middot; MIT-adjacent, see LICENSE</span>
          <span className="flex items-center gap-2">
            <span className="w-1.5 h-1.5 rounded-full bg-ember animate-pulse-dot" />
            crafted in Swift, rendered in Metal
          </span>
        </div>
      </div>

      {/* Giant ghost wordmark */}
      <div className="pointer-events-none select-none overflow-hidden -mb-8 md:-mb-16" aria-hidden>
        <p className="text-center font-display font-bold tracking-tightest leading-none text-[24vw] text-outline opacity-40 translate-y-[18%]">
          SOUL
        </p>
      </div>
    </footer>
  )
}
