import i18n, { FormatFunction } from 'i18next'
import LanguageDetector from 'i18next-browser-languagedetector'
import { initReactI18next } from 'react-i18next'
import { EN } from 'i18n/locales'

const formatFn: FormatFunction = (value, format) => {
  if (format === 'uppercase') return value.toUpperCase()
  if (format === 'lowercase') return value.toLowerCase()
  return value
}

const options = {
  lng: 'en',
  fallbackLng: ['en'],
  debug: false,
  interpolation: {
    format: formatFn,
    escapeValue: false
  },
  ns: ['shared', 'overview', 'analytics', 'applications', 'integration'],
  defaultNS: 'shared',
  react: {
    transKeepBasicHtmlNodesFor: ['br', 'strong', 'i']
  },
  resources: {
    en: {
      shared: EN.SHARED,
      overview: EN.OVERVIEW,
      analytics: EN.ANALYTICS,
      applications: EN.APPLICATIONS,
      integration: EN.INTEGRATION
    }
  }
}

i18n.use(LanguageDetector)
  .use(initReactI18next)
  .init(options)

export { i18n }
