import {render} from 'react-dom'
import React from 'react'
import {CustomPolicy} from 'Policies/components/CustomPolicy'

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('custom-policy-container')
  render(<CustomPolicy />, container)
})
