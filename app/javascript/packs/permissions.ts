import 'core-js/es7/array'

import { PermissionsFormWrapper } from 'Users/components/PermissionsForm'
import { safeFromJsonString } from 'utilities/json-utils'

import type { Props } from 'Users/components/PermissionsForm'

document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'user-permissions-form'
  const container = document.getElementById(containerId)

  if (!container) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const initialState = safeFromJsonString<Props['initialState']>(container.dataset.state)
  const services = safeFromJsonString<Props['services']>(container.dataset.services) ?? []
  const features = safeFromJsonString<Props['features']>(container.dataset.features) ?? []

  PermissionsFormWrapper({ features, initialState, services }, containerId)
})
