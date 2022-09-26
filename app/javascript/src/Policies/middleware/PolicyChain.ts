import { generateGuid } from 'Policies/util'
import { loadChainSuccess, loadChainError, updatePolicyChain } from 'Policies/actions/PolicyChain'
import { setOriginalPolicyChain } from 'Policies/actions/OriginalPolicyChain'

import type { ChainPolicy, RegistryPolicy, PolicyConfig, Dispatch, GetState, PolicyChainMiddlewareAction } from 'Policies/types'

function findRegistryPolicy (registry: Array<RegistryPolicy>, storedPolicy: PolicyConfig): RegistryPolicy | undefined {
  return registry.find(policy => (policy.name === storedPolicy.name && policy.version === storedPolicy.version))
}

function convertToChainPolicy (registryPolicy: RegistryPolicy, storedPolicy: PolicyConfig): ChainPolicy {
  const removable = !(storedPolicy.name === 'apicast')
  return {
    ...registryPolicy,
    enabled: storedPolicy.enabled,
    data: storedPolicy.configuration,
    removable,
    uuid: generateGuid()
  }
}

function removePolicy (chain: Array<ChainPolicy>, policy: ChainPolicy): Array<ChainPolicy> {
  return chain.filter(pol => pol.uuid !== policy.uuid)
}

const updatePolicy = (chain: Array<ChainPolicy>, policyConfig: ChainPolicy): Array<ChainPolicy> => {
  return chain.map(policy => (policy.uuid === policyConfig.uuid) ? policyConfig : policy)
}

const loadChain = ({
  registry,
  policiesConfig,
  dispatch
}: {
  registry: Array<RegistryPolicy>,
  policiesConfig: Array<PolicyConfig>,
  dispatch: Dispatch
}) => {
  let errors = 0
  const updatedChain: Array<ChainPolicy> = []
  policiesConfig.forEach(storedPolicy => {
    const foundRegistryPolicy = findRegistryPolicy(registry, storedPolicy)
    foundRegistryPolicy
      ? updatedChain.push(convertToChainPolicy(foundRegistryPolicy, storedPolicy))
      : errors++
  })
  if (errors > 0) {
    dispatch(loadChainError({})) // TODO: Define what to do with errors (unlikely now, just undefined path returned by Array.find)
  }

  dispatch(setOriginalPolicyChain(updatedChain))
  dispatch(loadChainSuccess(updatedChain))
}

const policyChainMiddleware = ({
  dispatch,
  getState
}: {
  dispatch: Dispatch,
  getState: GetState
}) => (next: Dispatch) => (action: PolicyChainMiddlewareAction) => {
  const state = getState()
  switch (action.type) {
    case 'LOAD_CHAIN':
      loadChain({ registry: state.registry, policiesConfig: action.policiesConfig, dispatch })
      break
    case 'REMOVE_POLICY_FROM_CHAIN':
      dispatch(updatePolicyChain(removePolicy(state.chain, action.policy)))
      break
    case 'UPDATE_POLICY_IN_CHAIN':
      dispatch(updatePolicyChain(updatePolicy(state.chain, action.policyConfig)))
      break
    default:
      return next(action)
  }
}

export {
  findRegistryPolicy,
  convertToChainPolicy,
  removePolicy,
  updatePolicy,
  loadChain,
  policyChainMiddleware
}
