import { Github, Heart, ExternalLink } from 'lucide-react'

export default function Footer() {
  return (
    <footer className="border-t border-white/5 bg-slate-950/50 backdrop-blur-sm">
      <div className="max-w-7xl mx-auto px-6 py-16">
        <div className="grid md:grid-cols-4 gap-12 mb-12">
          <div className="md:col-span-2 space-y-4">
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-accent-500/10 border border-accent-500/20 flex items-center justify-center">
                <svg width="18" height="18" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M11 19.5858L15 23.5858V29H7V23.5858L11 19.5858Z" fill="#fe8010"/>
                  <path d="M21.4142 10H10.5858L2 18.5858V30H30V18.5858L21.4142 10ZM11 12.4142L4 19.4142V28H18V19.4142L11 12.4142Z" fill="#fe8010" opacity="0.6"/>
                  <path d="M7 2C4.23858 2 2 4.23858 2 7C2 9.37733 3.65914 11.3671 5.88267 11.8747L9.17157 8.58579C9.54665 8.21071 10.0554 8 10.5858 8H11.9C11.9656 7.67689 12 7.34247 12 7C12 4.23858 9.76142 2 7 2Z" fill="#fe8010" opacity="0.8"/>
                </svg>
              </div>
              <span className="font-semibold text-lg">Soul</span>
            </div>
            <p className="text-sm text-slate-400 max-w-sm leading-relaxed">
              A native macOS AI browser built with SwiftUI, AppKit, and Chromium.
              Designed for power users who value privacy, performance, and craft.
            </p>
            <div className="flex items-center gap-4">
              <a
                href="https://github.com/soulcloude/mori-browser"
                target="_blank"
                rel="noopener noreferrer"
                className="w-9 h-9 rounded-lg bg-white/5 flex items-center justify-center text-slate-400 hover:text-white hover:bg-white/10 transition-colors"
              >
                <Github size={16} />
              </a>
            </div>
          </div>

          <div>
            <h4 className="text-sm font-semibold text-slate-200 mb-4">Project</h4>
            <ul className="space-y-3">
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
                    className="text-sm text-slate-400 hover:text-white transition-colors inline-flex items-center gap-1.5"
                  >
                    {link.label}
                    <ExternalLink size={10} className="opacity-50" />
                  </a>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="text-sm font-semibold text-slate-200 mb-4">Resources</h4>
            <ul className="space-y-3">
              {[
                { label: 'Architecture', href: '#architecture' },
                { label: 'Features', href: '#features' },
                { label: 'Showcase', href: '#showcase' },
                { label: 'License (MIT)', href: 'https://github.com/soulcloude/mori-browser/blob/main/LICENSE' },
              ].map((link) => (
                <li key={link.label}>
                  <a
                    href={link.href}
                    target={link.href.startsWith('http') ? '_blank' : undefined}
                    rel={link.href.startsWith('http') ? 'noopener noreferrer' : undefined}
                    className="text-sm text-slate-400 hover:text-white transition-colors inline-flex items-center gap-1.5"
                  >
                    {link.label}
                    {link.href.startsWith('http') && <ExternalLink size={10} className="opacity-50" />}
                  </a>
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="pt-8 border-t border-white/5 flex flex-col md:flex-row items-center justify-between gap-4 text-xs text-slate-500">
          <div className="flex items-center gap-1">
            <span>Made with</span>
            <Heart size={12} className="text-rose-500 fill-rose-500" />
            <span>for macOS</span>
          </div>
          <div className="flex items-center gap-4">
            <span>Soul Browser</span>
            <span className="text-slate-700">|</span>
            <span>MIT License</span>
          </div>
        </div>
      </div>
    </footer>
  )
}
