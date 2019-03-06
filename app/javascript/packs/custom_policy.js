import {render} from 'react-dom'
import React from 'react'
import {CustomPolicy} from 'Policies/components/CustomPolicy'
import {safeFromJson, parsePolicies} from 'Policies/util'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('custom-policy-container')
  const jsonPolicy = container.dataset.policy
  // TODO: Notify the user something has failed. Error messages.
  const props = (jsonPolicy) ? {policy: parsePolicies(safeFromJson(jsonPolicy, () => []))[0]} : {}
  render(<CustomPolicy {...props} />, container)
})
