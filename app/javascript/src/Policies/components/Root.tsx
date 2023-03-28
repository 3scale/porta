import { Provider } from 'react-redux'

import PoliciesWidget from 'Policies/components/PoliciesWidget'

import type { Store } from 'Policies/types'

interface Props {
  store: Store;
}

const Root: React.FunctionComponent<Props> = ({ store }) => (
  <Provider store={store}>
    <PoliciesWidget />
  </Provider>
)

export type { Props }
export { Root as default }
