import {render} from 'react-dom'
import React from 'react'
import {CustomPolicy} from 'Policies/components/CustomPolicy'
import {safeFromJson, parsePolicies} from 'Policies/util'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('custom-policy-container')
  // TODO: Notify the user something has failed. Error messages.
  const policy = parsePolicies(safeFromJson(container.dataset.policy, () => []))[0]
  render(<CustomPolicy policy={policy}/>, container)
})
