// @flow

import * as React from 'react'
import { PolicyTile } from 'Policies/components/PolicyTile'

import type {ShallowPolicy} from 'Policies/types'

import 'Policies/styles/policies.scss'

const policyEditLink = (id: number): string => `/p/admin/registry/policies/${id}/edit`

const navigateToEditPolicy = (url: string, win: Window = window) => {
  win.location.href = url
  win.history.pushState({}, '', url)
}

const PolicyList = function ({policies}: {policies: Array<ShallowPolicy>}): React.Node {
  return (
    <ul className='list-group PolicyList'>
      {policies.map((policy, index) => (
        <li className="Policy" key={index}><PolicyTile
          onClick={() => navigateToEditPolicy(policyEditLink(policy.id))}
          policy={policy}
        /></li>
      ))}
    </ul>
  )
}

export {
  PolicyList,
  policyEditLink,
  navigateToEditPolicy
}
