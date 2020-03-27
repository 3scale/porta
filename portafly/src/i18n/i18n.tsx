import i18n, { FormatFunction } from 'i18next'
import LanguageDetector from 'i18next-browser-languagedetector'
import { initReactI18next } from 'react-i18next'
import { ITranslationsPages, Translations, EN } from 'i18n'

const formatFn: FormatFunction = (value, format) => {
  if (format === 'uppercase') return value.toUpperCase()
  if (format === 'lowercase') return value.toLowerCase()
  return value
}

const sections: Array<ITranslationsPages> = ['shared', 'overview', 'analytics', 'applications', 'integration']

const options = {
  lng: EN,
  fallbackLng: [EN],
  debug: false,
  interpolation: {
    format: formatFn,
    escapeValue: false
  },
  ns: sections,
  defaultNS: 'shared',
  react: {
    transKeepBasicHtmlNodesFor: ['br', 'strong', 'i']
  },
  resources: Translations
}

i18n.use(LanguageDetector)
  .use(initReactI18next)
  .init(options)

export { i18n }
