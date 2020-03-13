import React, { useState } from 'react'
import { enUS, LOCALES } from 'i18n'

interface II18nContext {
  locale: LOCALES,
  setLocale: (l: LOCALES) => void
}

const I18nContext = React.createContext<II18nContext>({
  locale: enUS,
  setLocale: () => {}
})

const I18nProvider: React.FunctionComponent = ({ children }) => {
  const [locale, setLocale] = useState<LOCALES>(enUS)

  return (
    <I18nContext.Provider value={{ locale, setLocale }}>
      {children}
    </I18nContext.Provider>
  )
}

export { I18nContext, I18nProvider }
