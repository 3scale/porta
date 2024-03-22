import { Wrapper as AccountAuthenticationProviders } from 'AuthenticationProviders/components/AccountAuthenticationProviders'

import type { Props } from 'AuthenticationProviders/components/AccountAuthenticationProviders'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'account-authentication-providers'
  const container = document.getElementById(containerId)

  if (!container) {
    return
  }

  if (!container.dataset.props) {
    throw new Error('Missing AccountAuthenticationProviders props')
  }

  const props = JSON.parse(container.dataset.props) as Props

  AccountAuthenticationProviders(props, containerId)
})
