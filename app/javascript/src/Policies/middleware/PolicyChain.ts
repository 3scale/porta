import { generateGuid } from 'Policies/util'
import { loadChainError, loadChainSuccess, updatePolicyChain } from 'Policies/actions/PolicyChain'
import { setOriginalPolicyChain } from 'Policies/actions/OriginalPolicyChain'

import type { ChainPolicy, Dispatch, GetState, PolicyChainMiddlewareAction, PolicyConfig, RegistryPolicy } from 'Policies/types'

function findRegistryPolicy (registry: RegistryPolicy[], storedPolicy: PolicyConfig): RegistryPolicy | undefined {
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

function removePolicy (chain: ChainPolicy[], policy: ChainPolicy): ChainPolicy[] {
  return chain.filter(pol => pol.uuid !== policy.uuid)
}

const updatePolicy = (chain: ChainPolicy[], policyConfig: ChainPolicy): ChainPolicy[] => {
  return chain.map(policy => (policy.uuid === policyConfig.uuid) ? policyConfig : policy)
}

const loadChain = ({
  registry,
  policiesConfig,
  dispatch
}: {
  registry: RegistryPolicy[];
  policiesConfig: PolicyConfig[];
  dispatch: Dispatch;
}): void => {
  let errors = 0
  const updatedChain: ChainPolicy[] = []
  policiesConfig.forEach(storedPolicy => {
    const foundRegistryPolicy = findRegistryPolicy(registry, storedPolicy)
    // eslint-disable-next-line @typescript-eslint/no-unused-expressions
    foundRegistryPolicy
      ? updatedChain.push(convertToChainPolicy(foundRegistryPolicy, storedPolicy))
      : errors++
  })
  if (errors > 0) {
    void dispatch(loadChainError({})) // TODO: Define what to do with errors (unlikely now, just undefined path returned by Array.find)
  }

  void dispatch(setOriginalPolicyChain(updatedChain))
  void dispatch(loadChainSuccess(updatedChain))
}

const policyChainMiddleware = ({
  dispatch,
  getState
}: {
  dispatch: Dispatch;
  getState: GetState;
}) => (next: Dispatch) => (action: PolicyChainMiddlewareAction): unknown => {
  const state = getState()
  switch (action.type) {
    case 'LOAD_CHAIN':
      loadChain({ registry: state.registry, policiesConfig: action.policiesConfig, dispatch })
      break
    case 'REMOVE_POLICY_FROM_CHAIN':
      void dispatch(updatePolicyChain(removePolicy(state.chain, action.policy)))
      break
    case 'UPDATE_POLICY_IN_CHAIN':
      void dispatch(updatePolicyChain(updatePolicy(state.chain, action.policyConfig)))
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
