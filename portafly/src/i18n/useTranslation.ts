import { useTranslation, UseTranslationOptions } from 'react-i18next'
import { ITranslationsPages } from 'i18n'

/**
 * This wrapper mostly allow us to control what strings we pass
 * into useTranslation and provides the IDE with intellisense for
 * that matter.
 */
const useTranslationWrapper = (
  ns?: ITranslationsPages | Array<ITranslationsPages>,
  options?: UseTranslationOptions
) => useTranslation(ns, options)

export { useTranslationWrapper as useTranslation }
