/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        graphite: {
          950: '#07080a',
          900: '#0c0e12',
          850: '#11141a',
          800: '#171b24',
          700: '#222836',
          600: '#323b4e',
          500: '#4b556b',
        },
        neon: {
          purple: '#b829e3',
          'purple-glow': '#d946ef',
          'purple-dark': '#7e22ce',
          green: '#00ff87',
          'green-glow': '#10b981',
          'green-dark': '#059669',
          yellow: '#facc15',
          red: '#ef4444',
        }
      },
      fontFamily: {
        street: ['Impact', 'Teko', 'Cabinet Grotesk', 'sans-serif'],
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
      },
      boxShadow: {
        'neon-purple': '0 0 20px -3px rgba(184, 41, 227, 0.4), 0 0 8px -2px rgba(184, 41, 227, 0.3)',
        'neon-purple-lg': '0 0 35px -5px rgba(184, 41, 227, 0.6), 0 0 15px -3px rgba(184, 41, 227, 0.5)',
        'neon-green': '0 0 20px -3px rgba(0, 255, 135, 0.4), 0 0 8px -2px rgba(0, 255, 135, 0.3)',
        'neon-green-lg': '0 0 35px -5px rgba(0, 255, 135, 0.6), 0 0 15px -3px rgba(0, 255, 135, 0.5)',
      }
    },
  },
  plugins: [],
}