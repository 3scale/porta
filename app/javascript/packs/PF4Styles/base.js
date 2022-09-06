import '@babel/polyfill'
import 'patternflyStyles/pf4Base'
import { isBrowserIE11 } from 'utilities'

const isIE11 = isBrowserIE11(window)
if (isIE11) {
  // eslint-disable-next-line no-unused-expressions
  import('patternflyStyles/pf4BaseIE11.scss')
}
