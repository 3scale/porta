import { uiComponentTransition } from 'Policies/actions/UISettings'
import { fetchRegistry, loadRegistrySuccess } from 'Policies/actions/PolicyRegistry'
import {
  addPolicyToChain,
  fetchChain,
  loadChain,
  removePolicy,
  updatePolicyInChain
} from 'Policies/actions/PolicyChain'
import { updatePolicyConfig } from 'Policies/actions/PolicyConfig'

import type { UIComponent } from 'Policies/actions/UISettings'
import type { ChainPolicy, Dispatch, PolicyConfig, RegistryPolicy, ThunkAction } from 'Policies/types'

const chain: UIComponent = 'chain'
const registry: UIComponent = 'registry'
const policyConfig: UIComponent = 'policyConfig'

/**
 * Takes the @proxy.policies_config and @registry_policies from rails as props and
 * populates State's chain, originalChain and registry
 */
export const loadSavedPolicies = (policiesConfig: PolicyConfig[], registry: RegistryPolicy[]): ThunkAction => {
  return (dispatch: Dispatch) => {
    dispatch(loadRegistrySuccess(registry))
    dispatch(loadChain(policiesConfig))
  }
}

/**
 * Fetch @registry_policies and @proxy.policies from rails OR call loadSavedPolicies
 * if passed as arguments
 * TODO: remove this method and call fetch OR loadSaved
 */
export const populateChainFromConfigs = (
  serviceId: string,
  policiesConfig?: PolicyConfig[],
  registry?: RegistryPolicy[]
): ThunkAction => {
  return (dispatch: Dispatch) => {
    if (registry && policiesConfig) {
      dispatch(loadSavedPolicies(policiesConfig, registry))
    } else {
      dispatch(fetchRegistry())
      dispatch(fetchChain(serviceId))
    }
  }
}

/**
 * Copies a policy from the registry and adds it to the chain with a new UUID,
 * then hides the registry component and shows the policy chain.
 */
export const addPolicyFromRegistry = (policy: RegistryPolicy): ThunkAction => {
  return (dispatch: Dispatch) => {
    dispatch(addPolicyToChain(policy))
    dispatch(uiComponentTransition({ hide: registry, show: chain }))
  }
}

/**
 * Removes a policy from the policy chain and then hides the policy's
 * form and shows the policy chain component.
 */
export const removePolicyFromChain = (policy: ChainPolicy): ThunkAction => {
  return (dispatch: Dispatch) => {
    dispatch(removePolicy(policy))
    dispatch(uiComponentTransition({ hide: policyConfig, show: chain }))
  }
}

/**
 * Hides the policy chain component and shows the registry component
 */
export const openPolicyRegistry = (): ThunkAction => {
  return (dispatch: Dispatch) => {
    dispatch(uiComponentTransition({ hide: chain, show: registry }))
  }
}

/**
 * Hides the registry component and shows the policy chain component
 */
export const closePolicyRegistry = (): ThunkAction => {
  return (dispatch: Dispatch) => {
    dispatch(uiComponentTransition({ hide: registry, show: chain }))
  }
}

/**
 * Hides the policy chain component and shows a detail of a chain
 * policy with a form to edit it.
 */
export const openPolicyForm = (policy: ChainPolicy): ThunkAction => {
  return (dispatch: Dispatch) => {
    dispatch(updatePolicyConfig(policy))
    dispatch(uiComponentTransition({ hide: chain, show: policyConfig }))
  }
}

/**
 * Applies changes from the policy's form and updates it
 * in the policy chain array. Then hides the form and shows the
 * policy chain component.
 */
export const submitPolicyForm = (policyConfig: ChainPolicy): ThunkAction => {
  return (dispatch: Dispatch) => {
    dispatch(updatePolicyInChain(policyConfig))
    dispatch(closePolicyForm())
  }
}

/**
 * Hides the selected policy's detail, discarding any changes
 * made in the form, then shows the policy chain component.
 */
export const closePolicyForm = (): ThunkAction => {
  return (dispatch: Dispatch) => {
    dispatch(uiComponentTransition({ hide: policyConfig, show: chain }))
  }
}
