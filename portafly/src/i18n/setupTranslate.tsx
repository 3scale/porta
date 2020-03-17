import Polyglot from 'node-polyglot'

type Phrases = {
  [key: string]: string | object
}


export const setupTranslate = (polyglot:Polyglot , locale: string, phrases: Phrases) => {
  const t = polyglot.t.bind(polyglot)
  polyglot.locale(locale)  
  polyglot.extend(phrases)
  return t
}
