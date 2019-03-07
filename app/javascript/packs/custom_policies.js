import {render} from 'react-dom'
import React from 'react'
import {CustomPolicies} from 'Policies/components/CustomPolicies'
import {safeFromJson} from 'Policies/util'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('custom-policies-container')
  const policies = safeFromJson(container.dataset.policies)
  render(<CustomPolicies policies={policies} />, container)
})
