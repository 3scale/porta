import { RequestPasswordWrapper as RequestPassword } from 'Login/components/RequestPasswordPage'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props } from 'Login/components/RequestPasswordPage'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'pf-request-page-container'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const requestPageProps = safeFromJsonString<Props>(container.dataset.requestProps)

  if (!requestPageProps) {
    throw new Error('Missing props for RequestPage')
  }

  RequestPassword(requestPageProps, containerId)
})
