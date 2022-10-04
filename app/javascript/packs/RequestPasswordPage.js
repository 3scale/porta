import '@babel/polyfill'
import 'core-js/es7/object'
import { RequestPasswordWrapper as RequestPassword } from 'LoginPage'
import { safeFromJsonString } from 'utilities'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'pf-request-page-container'
  const container = document.getElementById(containerId)
  const requestPageProps = safeFromJsonString(container.dataset.requestProps)
  RequestPassword(requestPageProps, containerId)
})
