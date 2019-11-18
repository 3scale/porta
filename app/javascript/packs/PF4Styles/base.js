import '@babel/polyfill'
import {isBrowserIE11} from 'utilities/ie11Utils'
import 'patternflyStyles/pf4Base'

const isIE11 = isBrowserIE11(window)
if (isIE11) {
  import('patternflyStyles/pf4BaseIE11.scss')
}
