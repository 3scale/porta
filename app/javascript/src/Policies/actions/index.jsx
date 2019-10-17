// @flow

import { uiComponentTransition } from 'Policies/actions/UISettings'
import { fetchRegistry, loadRegistrySuccess } from 'Policies/actions/PolicyRegistry'

import {
  addPolicyToChain,
  removePolicy,
  sortPolicyChain,
  updatePolicyInChain,
  fetchChain,
  loadChain
} from 'Policies/actions/PolicyChain'

import { updatePolicyConfig } from 'Policies/actions/PolicyConfig'

import type { UIComponent } from 'Policies/actions/UISettings'
import type { Dispatch, RawRegistry, RegistryPolicy, ChainPolicy, StoredChainPolicy, IPoliciesActions, ThunkAction } from 'Policies/types'

const chainComponent: UIComponent = 'chain'
const registryComponent: UIComponent = 'registry'
const policyConfigComponent: UIComponent = 'policyConfig'

// Policies action creators
function loadSavedPolicies (chain: Array<StoredChainPolicy>, registry: RawRegistry): ThunkAction {
  return function (dispatch: Dispatch) {
    dispatch(loadRegistrySuccess(registry))
    dispatch(loadChain(chain))
  }
}

function populatePolicies (serviceId: string, chain?: Array<StoredChainPolicy>, registry?: RawRegistry): ThunkAction {
  return function (dispatch: Dispatch) {
    if (registry && chain) {
      dispatch(loadSavedPolicies(chain, registry))
    } else {
      dispatch(fetchRegistry())
      dispatch(fetchChain(serviceId))
    }
  }
}

// Chain action creators
function addPolicy (policy: RegistryPolicy): ThunkAction {
  return function (dispatch: Dispatch) {
    dispatch(addPolicyToChain(policy))
    dispatch(uiComponentTransition({hide: registryComponent, show: chainComponent}))
  }
}

function removePolicyFromChain (policy: ChainPolicy): ThunkAction {
  return function (dispatch: Dispatch) {
    dispatch(removePolicy(policy))
    dispatch(uiComponentTransition({hide: policyConfigComponent, show: chainComponent}))
  }
}

// Registry action creators
function openPolicyRegistry (): ThunkAction {
  return function (dispatch: Dispatch) {
    dispatch(uiComponentTransition({hide: chainComponent, show: registryComponent}))
  }
}

function closePolicyRegistry (): ThunkAction {
  return function (dispatch: Dispatch) {
    dispatch(uiComponentTransition({hide: registryComponent, show: chainComponent}))
  }
}

// Policy Config action creators
function editPolicy (policy: ChainPolicy): ThunkAction {
  return function (dispatch: Dispatch) {
    dispatch(updatePolicyConfig(policy))
    dispatch(uiComponentTransition({hide: chainComponent, show: policyConfigComponent}))
  }
}

function submitPolicyConfig (policyConfig: ChainPolicy): ThunkAction {
  return function (dispatch: Dispatch) {
    dispatch(updatePolicyConfig(policyConfig))
    dispatch(updatePolicyInChain(policyConfig))
    dispatch(uiComponentTransition({hide: policyConfigComponent, show: chainComponent}))
  }
}

function closePolicyConfig (): ThunkAction {
  return function (dispatch: Dispatch) {
    dispatch(uiComponentTransition({hide: policyConfigComponent, show: chainComponent}))
  }
}

export const actions: IPoliciesActions = {
  openPolicyRegistry,
  editPolicy,
  sortPolicyChain,
  submitPolicyConfig,
  removePolicyFromChain,
  closePolicyConfig,
  addPolicy,
  closePolicyRegistry,
  populatePolicies,
  updatePolicyConfig
}
