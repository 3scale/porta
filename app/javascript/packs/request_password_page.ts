import { RequestPasswordWrapper as RequestPassword } from 'LoginPage/RequestPasswordWrapper'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props } from 'LoginPage/RequestPasswordWrapper'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'pf-request-page-container'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- FIXME
  const requestPageProps = safeFromJsonString<Props>(container.dataset.requestProps)!
  RequestPassword(requestPageProps, containerId)
})
