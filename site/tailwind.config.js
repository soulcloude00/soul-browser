/** @type {import('tailwindcss').Config} */
export default {
  darkMode: 'class',
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        display: ['Space Grotesk', 'Inter', 'system-ui', 'sans-serif'],
        serif: ['"Instrument Serif"', 'Georgia', 'serif'],
        mono: ['"JetBrains Mono"', 'monospace'],
      },
      colors: {
        void: '#070605',
        coal: '#0d0b0a',
        smoke: '#161311',
        bone: '#f3efe7',
        ash: '#9b948a',
        dim: '#5f5a52',
        ember: {
          DEFAULT: '#ff5c1a',
          soft: '#ff7a42',
          deep: '#c93d05',
        },
      },
      letterSpacing: {
        tightest: '-0.05em',
      },
      animation: {
        'marquee': 'marquee 28s linear infinite',
        'pulse-dot': 'pulse-dot 2.4s ease-in-out infinite',
        'spin-slow': 'spin 14s linear infinite',
      },
      keyframes: {
        marquee: {
          '0%': { transform: 'translateX(0)' },
          '100%': { transform: 'translateX(-50%)' },
        },
        'pulse-dot': {
          '0%, 100%': { opacity: '1', transform: 'scale(1)' },
          '50%': { opacity: '0.4', transform: 'scale(0.7)' },
        },
      },
    },
  },
  plugins: [],
}
