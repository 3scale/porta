// TODO: remove this, please!

import {isBrowserIE11} from 'utilities'

const isIE11 = isBrowserIE11(window)
if (isIE11) {
  // eslint-disable-next-line no-unused-expressions
  import('utilities/patternflyStyles/pf4_base_ie11.scss')
}
