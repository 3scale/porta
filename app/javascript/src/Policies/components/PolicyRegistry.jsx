// @flow

import React from 'react'

import { isNotApicastPolicy } from 'Policies/components/util'
import { PolicyTile } from 'Policies/components/PolicyTile'

import type { RegistryPolicy, ThunkAction } from 'Policies/types'

type Props = {
  items: Array<RegistryPolicy>,
  actions: {
    addPolicy: (RegistryPolicy) => ThunkAction,
    closePolicyRegistry: () => ThunkAction
  }
}

const CloseRegistryButton = ({closePolicyRegistry}) => {
  return (
    <div className="PolicyChain-addPolicy--cancel" onClick={closePolicyRegistry}><i className="fa fa-times-circle"/> Cancel</div>
  )
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
      <header className="PolicyRegistryList-header">
        <h2 className="PolicyRegistryList-title">Select a Policy</h2>
        <CloseRegistryButton closePolicyRegistry={actions.closePolicyRegistry} />
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
