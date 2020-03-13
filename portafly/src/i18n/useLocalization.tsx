import { useContext } from 'react'
import Polyglot, { InterpolationOptions } from 'node-polyglot'
import { I18nContext, ITranslationsPages, TRANSLATIONS } from 'i18n'

type Page = Exclude<ITranslationsPages, 'common'>

/**
 * A custom hook to use localization on a given page.
 *
 * In order to use it properly, the component must be located
 * within a I18nProvider.
 *
 * @param page The page you want to get strings from. If no page
 * is provided, only common strings will be available.
 */
const useLocalization = (page?: Page) => {
  const { locale, setLocale } = useContext(I18nContext)

  const translations = TRANSLATIONS[locale]

  const phrases = {
    ...translations.common,
    ...page && translations[page]
  }

  const polyglot = new Polyglot({
    locale,
    phrases
  })

  return {
    t: (key: string, options?: number | InterpolationOptions) => polyglot.t(key, options),
    setLocale
  }
}

export { useLocalization }
