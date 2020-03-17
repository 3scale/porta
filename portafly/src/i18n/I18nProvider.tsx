import React from 'react'
import Polyglot from 'node-polyglot'

const polyglot = new Polyglot()
const I18nContext = React.createContext(polyglot)

const I18nProvider: React.FunctionComponent = (props)=> {
  return (
    <I18nContext.Provider value={polyglot}>
      {props.children}
    </I18nContext.Provider>
  )
}

export { I18nContext, I18nProvider }
