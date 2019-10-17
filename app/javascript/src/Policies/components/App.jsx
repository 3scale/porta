// @flow

import React from 'react'
import PoliciesWidget from 'Policies/components/PoliciesWidget'

import type { Store } from 'Policies/types'

type Props = {
  store: Store
}

const App = ({ store }: Props) => (
  <div>
    <PoliciesWidget store={store} />
  </div>
)

export default App
