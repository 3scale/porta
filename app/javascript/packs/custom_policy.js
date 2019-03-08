import {render} from 'react-dom'
import React from 'react'
import {CustomPolicy} from 'Policies/components/CustomPolicy'
import {safeFromJsonString} from 'Policies/util'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('custom-policy-container')
  const policy = safeFromJsonString(container.dataset.policy)
  render(<CustomPolicy policy={policy} />, container)
})
