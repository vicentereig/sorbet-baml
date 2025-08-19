/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{html,md,liquid,erb}",
    "./frontend/**/*.js",
  ],
  darkMode: 'media',
  theme: {
    extend: {
      colors: {
        'once-blue': {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
          950: '#082f49',
        },
        'once-gray': {
          50: '#f8fafc',
          100: '#f1f5f9',
          200: '#e2e8f0',
          300: '#cbd5e1',
          400: '#94a3b8',
          500: '#64748b',
          600: '#475569',
          700: '#334155',
          800: '#1e293b',
          900: '#0f172a',
        }
      },
      fontFamily: {
        'serif': [
          'ui-serif',
          'Georgia',
          'Cambria',
          '"Times New Roman"',
          'Times',
          'serif',
        ],
        'sans': [
          'ui-sans-serif',
          'system-ui',
          '-apple-system',
          'BlinkMacSystemFont',
          '"Segoe UI"',
          'Roboto',
          '"Helvetica Neue"',
          'Arial',
          'sans-serif',
        ]
      },
      maxWidth: {
        'prose': '65ch',
        'prose-wide': '75ch',
      },
      typography: {
        DEFAULT: {
          css: {
            maxWidth: '65ch',
            color: '#0f172a',
            fontSize: '1.125rem',
            lineHeight: '1.75',
            fontFamily: 'ui-serif, Georgia, Cambria, "Times New Roman", Times, serif',
            a: {
              color: '#0284c7',
              textDecoration: 'underline',
              textUnderlineOffset: '2px',
              fontWeight: '400',
              '&:hover': {
                color: '#0369a1',
              },
            },
            '[class~="lead"]': {
              color: '#475569',
              fontSize: '1.25rem',
              lineHeight: '1.75',
            },
            strong: {
              color: '#0c4a6e',
              fontWeight: '600',
            },
            'ol > li::before': {
              color: '#64748b',
            },
            'ul > li::before': {
              backgroundColor: '#cbd5e1',
            },
            hr: {
              borderColor: '#e2e8f0',
              borderTopWidth: 1,
              marginTop: '3rem',
              marginBottom: '3rem',
            },
            blockquote: {
              color: '#475569',
              borderLeftColor: '#bae6fd',
              borderLeftWidth: '4px',
              paddingLeft: '1rem',
              fontStyle: 'italic',
            },
            h1: {
              color: '#0c4a6e',
              fontWeight: '700',
              fontSize: '2.25rem',
              lineHeight: '1.25',
              marginTop: '0',
              marginBottom: '1rem',
              fontFamily: 'ui-sans-serif, system-ui, sans-serif',
            },
            h2: {
              color: '#075985',
              fontWeight: '600',
              fontSize: '1.875rem',
              lineHeight: '1.25',
              marginTop: '2rem',
              marginBottom: '1rem',
              fontFamily: 'ui-sans-serif, system-ui, sans-serif',
            },
            h3: {
              color: '#0369a1',
              fontWeight: '600',
              fontSize: '1.5rem',
              lineHeight: '1.25',
              marginTop: '1.5rem',
              marginBottom: '0.5rem',
              fontFamily: 'ui-sans-serif, system-ui, sans-serif',
            },
            h4: {
              color: '#0284c7',
              fontWeight: '600',
              fontSize: '1.25rem',
              lineHeight: '1.25',
              fontFamily: 'ui-sans-serif, system-ui, sans-serif',
            },
            'figure figcaption': {
              color: '#64748b',
              fontSize: '0.875rem',
            },
            code: {
              color: '#0c4a6e',
              backgroundColor: '#f0f9ff',
              padding: '0.125rem 0.25rem',
              borderRadius: '0.25rem',
              fontWeight: '400',
              fontSize: '0.875rem',
              fontFamily: 'ui-monospace, SFMono-Regular, monospace',
            },
            'code::before': {
              content: '""',
            },
            'code::after': {
              content: '""',
            },
            pre: {
              backgroundColor: '#0f172a',
              color: '#f0f9ff',
              borderRadius: '0.5rem',
              padding: '1rem',
              overflowX: 'auto',
            },
            'pre code': {
              backgroundColor: 'transparent',
              color: 'inherit',
              padding: '0',
              fontFamily: 'ui-monospace, SFMono-Regular, monospace',
            },
            p: {
              marginTop: '1.25rem',
              marginBottom: '1.25rem',
            },
            'ul, ol': {
              paddingLeft: '1.5rem',
            },
          },
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
}