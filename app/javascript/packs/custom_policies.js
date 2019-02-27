import {render} from 'react-dom'
import React from 'react'
import {PolicyList} from 'Policies/components/PolicyList'
import {parsePolicies} from 'Policies/util'

function parseJson (json) {
  try {
    return JSON.parse(json)
  } catch (err) {
    console.error('That doesn\'t look like a Policies Registry')
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('custom-policies-container')
  const policies = parsePolicies(parseJson(container.dataset.policies))
  render(<PolicyList items={policies} />, container)
})
