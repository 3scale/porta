import * as React from 'react';
import PropTypes from 'prop-types'
import { Provider } from 'react-redux'

import PoliciesWidget from 'Policies/components/PoliciesWidget'

import type { Store } from 'Policies/types'

type Props = {
  store: Store
};

const Root = (
  {
    store,
  }: Props,
): React.ReactElement => <Provider store={store}>
  <PoliciesWidget />
</Provider>

Root.propTypes = {
  store: PropTypes.object.isRequired
}

export default Root
