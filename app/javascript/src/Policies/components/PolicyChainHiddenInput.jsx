// @flow

import React from 'react'
import type { ChainPolicy } from '../types/Policies'

const filteredPolicyKeys = ['configuration', 'name', 'version', 'enabled']

function filterPolicyKeys (policy: ChainPolicy) {
  return Object.keys(policy)
    .filter(policyKey => filteredPolicyKeys.includes(policyKey))
    .reduce((filteredPolicy, key) => {
      filteredPolicy[key] = policy[key]
      return filteredPolicy
    }, {})
}

function parsePolicies (policies: Array<ChainPolicy>) {
  return policies.map(policy => filterPolicyKeys(policy))
}

const PolicyChainHiddenInput = ({policies}: {policies: Array<ChainPolicy>}) => {
  let data = JSON.stringify(parsePolicies(policies))
  return (
    <input
      type='hidden'
      id='proxy[policies_config]'
      name='proxy[policies_config]'
      value={data}
    />
  )
}

export { PolicyChainHiddenInput }
