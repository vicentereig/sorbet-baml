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
        'once-black': '#000000',
        'once-gray': {
          50: '#fafafa',
          100: '#f5f5f5',
          200: '#e5e5e5',
          300: '#d4d4d4',
          400: '#a3a3a3',
          500: '#737373',
          600: '#525252',
          700: '#404040',
          800: '#262626',
          900: '#171717',
        }
      },
      fontFamily: {
        'system': [
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
            color: '#171717',
            fontSize: '1rem',
            lineHeight: '1.625',
            a: {
              color: '#171717',
              textDecoration: 'underline',
              textUnderlineOffset: '2px',
              fontWeight: '400',
              '&:hover': {
                color: '#404040',
              },
            },
            '[class~="lead"]': {
              color: '#525252',
              fontSize: '1.125rem',
              lineHeight: '1.75',
            },
            strong: {
              color: '#000000',
              fontWeight: '600',
            },
            'ol > li::before': {
              color: '#737373',
            },
            'ul > li::before': {
              backgroundColor: '#d4d4d4',
            },
            hr: {
              borderColor: '#e5e5e5',
              borderTopWidth: 1,
              marginTop: '3rem',
              marginBottom: '3rem',
            },
            blockquote: {
              color: '#525252',
              borderLeftColor: '#d4d4d4',
              borderLeftWidth: '4px',
              paddingLeft: '1rem',
              fontStyle: 'normal',
            },
            h1: {
              color: '#000000',
              fontWeight: '700',
              fontSize: '2.25rem',
              lineHeight: '1.25',
              marginTop: '0',
              marginBottom: '1rem',
            },
            h2: {
              color: '#000000',
              fontWeight: '600',
              fontSize: '1.875rem',
              lineHeight: '1.25',
              marginTop: '2rem',
              marginBottom: '1rem',
            },
            h3: {
              color: '#171717',
              fontWeight: '600',
              fontSize: '1.5rem',
              lineHeight: '1.25',
              marginTop: '1.5rem',
              marginBottom: '0.5rem',
            },
            h4: {
              color: '#171717',
              fontWeight: '600',
              fontSize: '1.25rem',
              lineHeight: '1.25',
            },
            'figure figcaption': {
              color: '#737373',
              fontSize: '0.875rem',
            },
            code: {
              color: '#171717',
              backgroundColor: '#f5f5f5',
              padding: '0.125rem 0.25rem',
              borderRadius: '0.25rem',
              fontWeight: '400',
              fontSize: '0.875rem',
            },
            'code::before': {
              content: '""',
            },
            'code::after': {
              content: '""',
            },
            pre: {
              backgroundColor: '#171717',
              color: '#f5f5f5',
              borderRadius: '0.5rem',
              padding: '1rem',
              overflowX: 'auto',
            },
            'pre code': {
              backgroundColor: 'transparent',
              color: 'inherit',
              padding: '0',
            },
            p: {
              marginTop: '1rem',
              marginBottom: '1rem',
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