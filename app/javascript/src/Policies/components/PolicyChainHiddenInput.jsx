import React from 'react'
import type { ChainPolicy, StoredChainPolicy } from 'Policies/types/Policies'

const filteredPolicyKeys = ['configuration', 'name', 'version', 'enabled']

function filterPolicyKeys (policy: ChainPolicy): StoredChainPolicy {
  return Object.keys(policy)
    .filter(policyKey => filteredPolicyKeys.includes(policyKey))
    .reduce((filteredPolicy, key) => {
      filteredPolicy[key] = policy[key]
      return filteredPolicy
    }, {})
}

// TODO: Next iteration see if we can store the config as data field in Rails
function parsePolicy (policy: ChainPolicy): StoredChainPolicy {
  return {...filterPolicyKeys(policy), ...{configuration: policy.data}}
}

function parsePolicies (policies: Array<ChainPolicy>) {
  return policies.map(policy => parsePolicy(policy))
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
