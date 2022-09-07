import {uiComponentTransition} from 'Policies/actions/UISettings';
import { fetchRegistry, loadRegistrySuccess } from 'Policies/actions/PolicyRegistry'

import {
  addPolicyToChain,
  removePolicy,
  updatePolicyInChain,
  fetchChain,
  loadChain
} from 'Policies/actions/PolicyChain'

import { updatePolicyConfig } from 'Policies/actions'

import type { UIComponent } from 'Policies/actions/UISettings'
import type { Dispatch, RegistryPolicy, ChainPolicy, PolicyConfig, ThunkAction } from 'Policies/types'

const chain: UIComponent = 'chain'
const registry: UIComponent = 'registry'
const policyConfig: UIComponent = 'policyConfig'

/**
 * Takes the @proxy.policies_config and @registry_policies from rails as props and
 * populates State's chain, originalChain and registry
 */
export function loadSavedPolicies(policiesConfig: Array<PolicyConfig>, registry: Array<RegistryPolicy>): ThunkAction {
  return function (dispatch: Dispatch) {
    dispatch(loadRegistrySuccess(registry))
    dispatch(loadChain(policiesConfig))
  };
}

/**
 * Fetch @registry_policies and @proxy.policies from rails OR call loadSavedPolicies
 * if passed as arguments
 * TODO: remove this method and call fetch OR loadSaved
 */
export function populateChainFromConfigs(
  serviceId: string,
  policiesConfig?: Array<PolicyConfig>,
  registry?: Array<RegistryPolicy>,
): ThunkAction {
  return function (dispatch: Dispatch) {
    if (registry && policiesConfig) {
      dispatch(loadSavedPolicies(policiesConfig, registry))
    } else {
      dispatch(fetchRegistry())
      dispatch(fetchChain(serviceId))
    }
  };
}

/**
 * Copies a policy from the registry and adds it to the chain with a new UUID,
 * then hides the registry component and shows the policy chain.
 */
export function addPolicyFromRegistry(policy: RegistryPolicy): ThunkAction {
  return function (dispatch: Dispatch) {
    dispatch(addPolicyToChain(policy))
    dispatch(uiComponentTransition({hide: registry, show: chain}))
  };
}

/**
 * Removes a policy from the policy chain and then hides the policy's
 * form and shows the policy chain component.
 */
export function removePolicyFromChain(policy: ChainPolicy): ThunkAction {
  return function (dispatch: Dispatch) {
    dispatch(removePolicy(policy))
    dispatch(uiComponentTransition({hide: policyConfig, show: chain}))
  };
}

/**
 * Hides the policy chain component and shows the registry component
 */
export function openPolicyRegistry(): ThunkAction {
  return function (dispatch: Dispatch) {
    dispatch(uiComponentTransition({hide: chain, show: registry}))
  };
}

/**
 * Hides the registry component and shows the policy chain component
 */
export function closePolicyRegistry(): ThunkAction {
  return function (dispatch: Dispatch) {
    dispatch(uiComponentTransition({hide: registry, show: chain}))
  };
}

/**
 * Hides the policy chain component and shows a detail of a chain
 * policy with a form to edit it.
 */
export function openPolicyForm(policy: ChainPolicy): ThunkAction {
  return function (dispatch: Dispatch) {
    dispatch(updatePolicyConfig(policy))
    dispatch(uiComponentTransition({hide: chain, show: policyConfig}))
  };
}

/**
 * Applies changes from the policy's form and updates it
 * in the policy chain array. Then hides the form and shows the
 * policy chain component.
 */
export function submitPolicyForm(policyConfig: ChainPolicy): ThunkAction {
  return function (dispatch: Dispatch) {
    dispatch(updatePolicyInChain(policyConfig))
    dispatch(closePolicyForm())
  };
}

/**
 * Hides the selected policy's detail, discarding any changes
 * made in the form, then shows the policy chain component.
 */
export function closePolicyForm(): ThunkAction {
  return function (dispatch: Dispatch) {
    dispatch(uiComponentTransition({hide: policyConfig, show: chain}))
  };
}
