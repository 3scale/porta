import {render} from 'react-dom'
import React from 'react'
import {CustomPolicies} from 'Policies/components/CustomPolicies'
import {safeFromJsonString} from 'Policies/util'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('custom-policies-container')
  const policies = safeFromJsonString(container.dataset.policies)
  render(<CustomPolicies policies={policies} />, container)
})
