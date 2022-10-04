
import Root from 'Policies/components/Root'
import configureStore from 'Policies/store/configureStore'
import { initialState } from 'Policies/reducers/initialState'
import { populateChainFromConfigs } from 'Policies/actions'
import { createReactWrapper } from 'utilities'
import 'Policies/styles/policies.scss'

import type { Action, PolicyConfig, RegistryPolicy } from 'Policies/types'

type PoliciesProps = {
  registry: RegistryPolicy[],
  chain: PolicyConfig[],
  serviceId: string
}

const PoliciesWrapper = ({ registry, chain, serviceId }: PoliciesProps, elementId: string): void => {
  const store = configureStore(initialState)
  store.dispatch(populateChainFromConfigs(serviceId, chain, registry) as unknown as Action)

  return createReactWrapper(<Root store={store} />, elementId)
}

export { PoliciesWrapper }
