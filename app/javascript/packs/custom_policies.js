import {render} from 'react-dom'
import React from 'react'
import {CustomPolicies} from 'Policies/components/CustomPolicies'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('custom-policies-container')
  render(<CustomPolicies jsonPolicies={container.dataset.policies} />, container)
})
