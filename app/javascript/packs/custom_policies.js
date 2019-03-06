import {render} from 'react-dom'
import React from 'react'
import {CustomPolicies} from 'Policies/components/CustomPolicies'
import {safeFromJson, parsePolicies} from 'Policies/util'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('custom-policies-container')
  // TODO: Notify the user something has failed. Error messages.
  const policies = parsePolicies(safeFromJson(container.dataset.policies, () => []))
  render(<CustomPolicies policies={policies} />, container)
})
