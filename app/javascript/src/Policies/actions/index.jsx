// @flow

import type { Dispatch, ThunkAction } from 'types/index'
import type {
  RawRegistry,
  RegistryPolicy,
  ChainPolicy,
  StoredChainPolicy
} from 'types/Policies'
import type { UIComponent } from 'Policies/actions/UISettings'

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

const chainComponent: UIComponent = 'chain'
const registryComponent: UIComponent = 'registry'
const policyConfigComponent: UIComponent = 'policyConfig'

// Policies action creators
function loadSavedPolicies (policies: {chain: Array<StoredChainPolicy>, registry: RawRegistry}): ThunkAction {
  return function (dispatch: Dispatch) {
    dispatch(loadRegistrySuccess(policies.registry))
    dispatch(loadChain(policies.chain))
  }
}

function populatePolicies (serviceId: string, policies?: {chain: Array<StoredChainPolicy>, registry: RawRegistry}): ThunkAction {
  return function (dispatch: Dispatch) {
    if (policies) {
      dispatch(loadSavedPolicies(policies))
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

export {
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
