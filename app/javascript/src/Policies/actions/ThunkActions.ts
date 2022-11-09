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

const CHAIN: UIComponent = 'chain'
const REGISTRY: UIComponent = 'registry'
const POLICY_CONFIG: UIComponent = 'policyConfig'

/**
 * Takes the @proxy.policies_config and @registry_policies from rails as props and
 * populates State's chain, originalChain and registry
 */
export const loadSavedPolicies = (policiesConfig: PolicyConfig[], registry: RegistryPolicy[]): ThunkAction => {
  return (dispatch: Dispatch) => {
    void dispatch(loadRegistrySuccess(registry))
    void dispatch(loadChain(policiesConfig))
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
      void dispatch(loadSavedPolicies(policiesConfig, registry))
    } else {
      void dispatch(fetchRegistry())
      void dispatch(fetchChain(serviceId))
    }
  }
}

/**
 * Copies a policy from the registry and adds it to the chain with a new UUID,
 * then hides the registry component and shows the policy chain.
 */
export const addPolicyFromRegistry = (policy: RegistryPolicy): ThunkAction => {
  return (dispatch: Dispatch) => {
    void dispatch(addPolicyToChain(policy))
    void dispatch(uiComponentTransition({ hide: REGISTRY, show: CHAIN }))
  }
}

/**
 * Removes a policy from the policy chain and then hides the policy's
 * form and shows the policy chain component.
 */
export const removePolicyFromChain = (policy: ChainPolicy): ThunkAction => {
  return (dispatch: Dispatch) => {
    void dispatch(removePolicy(policy))
    void dispatch(uiComponentTransition({ hide: POLICY_CONFIG, show: CHAIN }))
  }
}

/**
 * Hides the policy chain component and shows the registry component
 */
export const openPolicyRegistry = (): ThunkAction => {
  return (dispatch: Dispatch) => {
    void dispatch(uiComponentTransition({ hide: CHAIN, show: REGISTRY }))
  }
}

/**
 * Hides the registry component and shows the policy chain component
 */
export const closePolicyRegistry = (): ThunkAction => {
  return (dispatch: Dispatch) => {
    void dispatch(uiComponentTransition({ hide: REGISTRY, show: CHAIN }))
  }
}

/**
 * Hides the policy chain component and shows a detail of a chain
 * policy with a form to edit it.
 */
export const openPolicyForm = (policy: ChainPolicy): ThunkAction => {
  return (dispatch: Dispatch) => {
    void dispatch(updatePolicyConfig(policy))
    void dispatch(uiComponentTransition({ hide: CHAIN, show: POLICY_CONFIG }))
  }
}

/**
 * Applies changes from the policy's form and updates it
 * in the policy chain array. Then hides the form and shows the
 * policy chain component.
 */
export const submitPolicyForm = (policyConfig: ChainPolicy): ThunkAction => {
  return (dispatch: Dispatch) => {
    void dispatch(updatePolicyInChain(policyConfig))
    void dispatch(closePolicyForm())
  }
}

/**
 * Hides the selected policy's detail, discarding any changes
 * made in the form, then shows the policy chain component.
 */
export const closePolicyForm = (): ThunkAction => {
  return (dispatch: Dispatch) => {
    void dispatch(uiComponentTransition({ hide: POLICY_CONFIG, show: CHAIN }))
  }
}
