import {render} from 'react-dom'
import React from 'react'
import {CustomPolicy} from 'Policies/components/CustomPolicy'
import {safeFromJson} from 'Policies/util'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('custom-policy-container')
  const jsonPolicy = container.dataset.policy
  const props = (jsonPolicy) ? {policy: safeFromJson(jsonPolicy)} : {}
  render(<CustomPolicy {...props} />, container)
})
