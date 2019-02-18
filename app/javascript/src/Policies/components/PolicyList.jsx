// @flow

import * as React from 'react'
import { PolicyTile } from 'Policies/components/PolicyTile'
import 'Policies/styles/policies.scss'
import type {RegistryPolicy} from 'Policies/types/Policies'

const policyEditLink = (id: string): string => `/p/admin/custom_policies/${id}/edit`

const navigateToEditPolicy = (url: string) => {
  window.location.href = url
  history.pushState({}, '', url)
}

const PolicyList = function ({items}: {items: Array<&RegistryPolicy & {id: string}>}): React.Node {
  return (
    <ul className='list-group'>
      {items.map((policy, index) => (
        <PolicyTile
          edit={() => navigateToEditPolicy(policyEditLink(policy.id))}
          policy={policy}
          key={index}
        />
      ))}
    </ul>
  )
}

export { PolicyList }
