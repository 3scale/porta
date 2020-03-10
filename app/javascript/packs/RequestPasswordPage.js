import '@babel/polyfill'
import 'core-js/es7/object'

import { RequestPasswordWrapper as RequestPassword } from 'LoginPage'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('pf-request-page-container')
  const requestPageProps = safeFromJsonString(container.dataset.requestProps)
  RequestPassword(requestPageProps, 'pf-request-page-container')
})
