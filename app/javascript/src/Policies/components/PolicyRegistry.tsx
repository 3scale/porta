import * as React from 'react';

import { isNotApicastPolicy } from 'Policies/util'
import { PolicyTile } from 'Policies/components/PolicyTile'
import { HeaderButton } from 'Policies/components/HeaderButton'

import type { RegistryPolicy, ThunkAction } from 'Policies/types'

type Props = {
  items: Array<RegistryPolicy>,
  actions: {
    addPolicy: (arg1: RegistryPolicy) => ThunkAction,
    closePolicyRegistry: () => ThunkAction
  }
};

const PolicyRegistry = (
  {
    items,
    actions: { addPolicy, closePolicyRegistry },
  }: Props,
): React.ReactElement => <section className="PolicyRegistry">
  <header>
    <h2>Select a Policy</h2>
    <HeaderButton type='cancel' onClick={closePolicyRegistry}>
      Cancel
    </HeaderButton>
  </header>
  <ul className="list-group">
    {items.filter(isNotApicastPolicy).map(p => (
      <li className="Policy" key={p.name}>
        <PolicyTile policy={p} onClick={() => addPolicy(p)} title="Add this Policy" />
      </li>
    ))}
  </ul>
</section>

export { PolicyRegistry }
