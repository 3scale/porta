import { Provider } from 'react-redux'
import PoliciesWidget from 'Policies/components/PoliciesWidget'

import type { Store } from 'Policies/types'

type Props = {
  store: Store,
}

const Root: React.FunctionComponent<Props> = ({ store }) => (
  <Provider store={store}>
    <PoliciesWidget />
  </Provider>
)

export { Root as default, Props }
