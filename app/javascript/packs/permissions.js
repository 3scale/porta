import 'core-js/es7/array'

import React from 'react'
import { render } from 'react-dom'

import { PermissionsForm } from 'Users/components/PermissionsForm'
import { safeFromJsonString } from 'utilities/json-utils'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('user-permissions-form')

  const initialState = safeFromJsonString(container.dataset.state)
  const services = safeFromJsonString(container.dataset.services)
  const features = safeFromJsonString(container.dataset.features)

  render(<PermissionsForm initialState={initialState} services={services} features={features} />, container)
})
