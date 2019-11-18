// @flow

import React from 'react'

import { isNotApicastPolicy } from 'Policies/components/util'
import { PolicyTile } from 'Policies/components/PolicyTile'
import { HeaderButton } from 'Policies/components/HeaderButton'

import type { RegistryPolicy, ThunkAction } from 'Policies/types'

type Props = {
  items: Array<RegistryPolicy>,
  actions: {
    addPolicy: (RegistryPolicy) => ThunkAction,
    closePolicyRegistry: () => ThunkAction
  }
}

const PolicyRegistryItem = ({value, addPolicy}: {value: RegistryPolicy, addPolicy: (RegistryPolicy) => ThunkAction}) => {
  const addToChain = () => void addPolicy(value)
  return (
    <li className="Policy">
      <PolicyTile policy={value} onClick={addToChain} title='Add this Policy.'/>
    </li>
  )
}

const PolicyRegistry = ({ items, actions }: Props) => {
  return (
    <section className="PolicyRegistryList">
      <header>
        <h2>Select a Policy</h2>
        <HeaderButton type='cancel' onClick={actions.closePolicyRegistry}>
        Cancel
        </HeaderButton>
      </header>
      <ul className="list-group">
        {items.filter(policy => isNotApicastPolicy(policy)).map((policy, index) => (
          <PolicyRegistryItem key={`item-${index}`} index={index} value={policy} addPolicy={actions.addPolicy} />
        ))}
      </ul>
    </section>
  )
}

export {
  PolicyRegistry,
  PolicyRegistryItem
}
