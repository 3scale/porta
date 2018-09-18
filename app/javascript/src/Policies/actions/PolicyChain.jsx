// @flow

import { RSAA } from 'redux-api-middleware'

import type { RSSAAction } from '../types/index'
import type { RegistryPolicy, ChainPolicy, StoredChainPolicy } from '../types/Policies'

export type AddPolicyToChainAction = { type: 'ADD_POLICY_TO_CHAIN', policy: RegistryPolicy }
export function addPolicyToChain (policy: RegistryPolicy): AddPolicyToChainAction {
  return { type: 'ADD_POLICY_TO_CHAIN', policy }
}

export type RemovePolicyFromChainAction = { type: 'REMOVE_POLICY_FROM_CHAIN', policy: ChainPolicy }
export function removePolicy (policy: ChainPolicy): RemovePolicyFromChainAction {
  return { type: 'REMOVE_POLICY_FROM_CHAIN', policy }
}

export type SortPolicyChainAction = { type: 'SORT_POLICY_CHAIN', payload: Array<ChainPolicy> }
export function sortPolicyChain (payload: Array<ChainPolicy>): SortPolicyChainAction {
  return { type: 'SORT_POLICY_CHAIN', payload }
}

export type UpdatePolicyInChainAction = { type: 'UPDATE_POLICY_IN_CHAIN', policyConfig: ChainPolicy }
export function updatePolicyInChain (policyConfig: ChainPolicy): UpdatePolicyInChainAction {
  return { type: 'UPDATE_POLICY_IN_CHAIN', policyConfig }
}

export type UpdatePolicyChainAction = { type: 'UPDATE_POLICY_CHAIN', payload: Array<ChainPolicy> }
export function updatePolicyChain (payload: Array<ChainPolicy>): UpdatePolicyChainAction {
  return { type: 'UPDATE_POLICY_CHAIN', payload }
}

export type LoadChainAction = { type: 'LOAD_CHAIN', storedChain: Array<StoredChainPolicy> }
export function loadChain (storedChain: Array<StoredChainPolicy>): LoadChainAction {
  return { type: 'LOAD_CHAIN', storedChain }
}

export type LoadChainSuccessAction = { type: 'LOAD_CHAIN_SUCCESS', payload: Array<ChainPolicy> }
export function loadChainSuccess (payload: Array<ChainPolicy>): LoadChainSuccessAction {
  return { type: 'LOAD_CHAIN_SUCCESS', payload }
}

export type LoadChainErrorAction = { type: 'LOAD_CHAIN_ERROR', payload: Object }
export function loadChainError (payload: Object): LoadChainErrorAction {
  return { type: 'LOAD_CHAIN_ERROR', payload }
}

export type FetchChainSuccessAction = { type: 'FETCH_CHAIN_SUCCESS', payload: Array<ChainPolicy> }
export type FetchChainErrorAction = { type: 'FETCH_CHAIN_ERROR', payload: Object }

const REQUEST = { type: 'FETCH_CHAIN_REQUEST' }
const SUCCESS = { type: 'FETCH_CHAIN_SUCCESS' }
const FAILURE = { type: 'FETCH_CHAIN_ERROR' }

export function fetchChain (serviceId: string): RSSAAction {
  return {
    [RSAA]: {
      endpoint: `/admin/api/services/${serviceId}/proxy/policies.json`,
      method: 'GET',
      credentials: 'same-origin',
      types: [REQUEST, SUCCESS, FAILURE]
    }
  }
}
