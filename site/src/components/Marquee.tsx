const items = [
  'Pure Swift',
  'CEF 148 / Chromium',
  '120Hz Metal',
  'Local-first AI',
  'Zero telemetry',
  'Vertical tabs',
  'Liquid Glass',
  'Anti-fingerprinting',
]

export default function Marquee() {
  const row = [...items, ...items]
  return (
    <div className="relative py-10 border-y hairline overflow-hidden select-none" aria-hidden>
      <div className="absolute inset-y-0 left-0 w-32 bg-gradient-to-r from-void to-transparent z-10 pointer-events-none" />
      <div className="absolute inset-y-0 right-0 w-32 bg-gradient-to-l from-void to-transparent z-10 pointer-events-none" />
      <div className="flex w-max animate-marquee gap-0 whitespace-nowrap">
        {row.map((item, i) => (
          <span key={i} className="flex items-center">
            <span className="font-display text-2xl md:text-4xl font-medium tracking-tight text-dim hover:text-bone transition-colors px-6">
              {item}
            </span>
            <span className="text-ember text-xl md:text-3xl">✦</span>
          </span>
        ))}
      </div>
    </div>
  )
}
