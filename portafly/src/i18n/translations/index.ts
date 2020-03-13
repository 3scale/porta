import * as Locales from 'i18n/locales'
import enUsTranslations from './en-us.json'
import jaJpTranslations from './ja-jp.json'

// TODO: Can we abstract this type from enUsTranslations?
export type ITranslationsPages = keyof typeof enUsTranslations
export type ITranslations = { [P in ITranslationsPages]: any}

export const TRANSLATIONS: Record<Locales.LOCALES, ITranslations> = {
  [Locales.enUS]: enUsTranslations,
  [Locales.jaJP]: jaJpTranslations
}
