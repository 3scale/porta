import '@babel/polyfill'
import 'core-js/es7/object'
import { isBrowserIE11 } from 'utilities/ie11Utils'

const isIE11 = isBrowserIE11(window)
if (isIE11) {
  // eslint-disable-next-line no-unused-expressions
  import('LoginPage/assets/styles/ie11-pf4BaseStyles.css')
}

import { RequestPasswordWrapper } from 'LoginPage'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('pf-request-page-container')
  if (isIE11) {
    container.classList.add('isIe11', 'pf-c-page')
  }
  const requestPageProps = safeFromJsonString(container.dataset.requestProps)
  RequestPasswordWrapper(requestPageProps, 'pf-request-page-container')
})
