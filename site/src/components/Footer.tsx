import { Github, Heart, ExternalLink } from 'lucide-react'

export default function Footer() {
  return (
    <footer className="border-t border-white/[0.03] bg-[#0a0a0f]/80 backdrop-blur-sm">
      <div className="max-w-6xl mx-auto px-6 py-14">
        <div className="grid md:grid-cols-4 gap-10 mb-10">
          <div className="md:col-span-2 space-y-3">
            <div className="flex items-center gap-2">
              <div className="w-7 h-7 rounded-md bg-gradient-to-br from-orange-400/20 to-orange-600/10 border border-orange-500/20 flex items-center justify-center">
                <svg width="14" height="14" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M11 19.5858L15 23.5858V29H7V23.5858L11 19.5858Z" fill="#fb923c"/>
                  <path d="M21.4142 10H10.5858L2 18.5858V30H30V18.5858L21.4142 10ZM11 12.4142L4 19.4142V28H18V19.4142L11 12.4142Z" fill="#fb923c" opacity="0.5"/>
                  <path d="M7 2C4.23858 2 2 4.23858 2 7C2 9.37733 3.65914 11.3671 5.88267 11.8747L9.17157 8.58579C9.54665 8.21071 10.0554 8 10.5858 8H11.9C11.9656 7.67689 12 7.34247 12 7C12 4.23858 9.76142 2 7 2Z" fill="#fb923c" opacity="0.7"/>
                </svg>
              </div>
              <span className="font-display font-semibold text-[16px] text-white/90">Soul</span>
            </div>
            <p className="text-sm text-slate-500 max-w-sm leading-[1.7]">
              A native macOS AI browser built with SwiftUI, AppKit, and Chromium.
              For power users who value privacy, performance, and craft.
            </p>
            <div className="flex items-center gap-3 pt-1">
              <a
                href="https://github.com/soulcloude/mori-browser"
                target="_blank"
                rel="noopener noreferrer"
                className="w-8 h-8 rounded-lg bg-white/[0.03] border border-white/[0.05] flex items-center justify-center text-slate-500 hover:text-white hover:bg-white/[0.06] hover:border-white/10 transition-all duration-300 active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-white/10"
              >
                <Github size={14} />
              </a>
            </div>
          </div>

          <div>
            <h4 className="text-xs font-semibold text-white/70 mb-3 tracking-wide uppercase">Project</h4>
            <ul className="space-y-2">
              {[
                { label: 'README', href: 'https://github.com/soulcloude/mori-browser/blob/main/README.md' },
                { label: 'Roadmap', href: 'https://github.com/soulcloude/mori-browser/blob/main/ROADMAP.md' },
                { label: 'Progress', href: 'https://github.com/soulcloude/mori-browser/blob/main/PROGRESS.md' },
                { label: 'Contributing', href: 'https://github.com/soulcloude/mori-browser/blob/main/CONTRIBUTING.md' },
              ].map((link) => (
                <li key={link.label}>
                  <a
                    href={link.href}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-sm text-slate-500 hover:text-white transition-colors inline-flex items-center gap-1 active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-white/10 rounded-md px-1 -ml-1"
                  >
                    {link.label}
                    <ExternalLink size={9} className="opacity-30" />
                  </a>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="text-xs font-semibold text-white/70 mb-3 tracking-wide uppercase">Resources</h4>
            <ul className="space-y-2">
              {[
                { label: 'Architecture', href: '#architecture' },
                { label: 'Features', href: '#features' },
                { label: 'Showcase', href: '#showcase' },
                { label: 'License', href: 'https://github.com/soulcloude/mori-browser/blob/main/LICENSE' },
              ].map((link) => (
                <li key={link.label}>
                  <a
                    href={link.href}
                    target={link.href.startsWith('http') ? '_blank' : undefined}
                    rel={link.href.startsWith('http') ? 'noopener noreferrer' : undefined}
                    className="text-sm text-slate-500 hover:text-white transition-colors inline-flex items-center gap-1 active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-white/10 rounded-md px-1 -ml-1"
                  >
                    {link.label}
                    {link.href.startsWith('http') && <ExternalLink size={9} className="opacity-30" />}
                  </a>
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="pt-6 border-t border-white/[0.03] flex flex-col md:flex-row items-center justify-between gap-3 text-xs text-slate-600">
          <div className="flex items-center gap-1">
            <span>Made with</span>
            <Heart size={10} className="text-rose-500/70 fill-rose-500/70" />
            <span>for macOS</span>
          </div>
          <div className="flex items-center gap-3">
            <span>Soul Browser</span>
            <span className="text-slate-800">|</span>
            <span>MIT License</span>
          </div>
        </div>
      </div>
    </footer>
  )
}
