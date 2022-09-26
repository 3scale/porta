import { RSAA, RSAAAction } from 'redux-api-middleware'

import { RegistryPolicy, ChainPolicy, PolicyConfig } from 'Policies/types'
import { Action } from 'redux'

export type AddPolicyToChainAction = Action<'ADD_POLICY_TO_CHAIN'> & {
  policy: RegistryPolicy
};
export function addPolicyToChain (policy: RegistryPolicy): AddPolicyToChainAction {
  return { type: 'ADD_POLICY_TO_CHAIN', policy }
}

export type RemovePolicyFromChainAction = Action<'REMOVE_POLICY_FROM_CHAIN'> & {
  policy: ChainPolicy
};
export function removePolicy (policy: ChainPolicy): RemovePolicyFromChainAction {
  return { type: 'REMOVE_POLICY_FROM_CHAIN', policy }
}

export type SortPolicyChainAction = Action<'SORT_POLICY_CHAIN'> & {
  payload: Array<ChainPolicy>
};
export function sortPolicyChain (payload: Array<ChainPolicy>): SortPolicyChainAction {
  return { type: 'SORT_POLICY_CHAIN', payload }
}

export type UpdatePolicyInChainAction = Action<'UPDATE_POLICY_IN_CHAIN'> & {
  policyConfig: ChainPolicy
};
export function updatePolicyInChain (policyConfig: ChainPolicy): UpdatePolicyInChainAction {
  return { type: 'UPDATE_POLICY_IN_CHAIN', policyConfig }
}

export type UpdatePolicyChainAction = Action<'UPDATE_POLICY_CHAIN'> & {
  payload: Array<ChainPolicy>
};
export function updatePolicyChain (payload: Array<ChainPolicy>): UpdatePolicyChainAction {
  return { type: 'UPDATE_POLICY_CHAIN', payload }
}

export type LoadChainAction = Action<'LOAD_CHAIN'> & {
  policiesConfig: Array<PolicyConfig>
};
export function loadChain (policiesConfig: Array<PolicyConfig>): LoadChainAction {
  return { type: 'LOAD_CHAIN', policiesConfig }
}

export type LoadChainSuccessAction = Action<'LOAD_CHAIN_SUCCESS'> & {
  payload: Array<ChainPolicy>
};
export function loadChainSuccess (payload: Array<ChainPolicy>): LoadChainSuccessAction {
  return { type: 'LOAD_CHAIN_SUCCESS', payload }
}

export type LoadChainErrorAction = Action<'LOAD_CHAIN_ERROR'> & {
  payload: Record<any, any>
};
export function loadChainError (payload: Record<any, any>): LoadChainErrorAction {
  return { type: 'LOAD_CHAIN_ERROR', payload }
}

export type FetchChainSuccessAction = Action<'FETCH_CHAIN_SUCCESS'> & {
  payload: Array<ChainPolicy>
};
export type FetchChainErrorAction = Action<'FETCH_CHAIN_ERROR'> & {
  payload: Record<any, any>
};

const REQUEST = { type: 'FETCH_CHAIN_REQUEST' } as const
const SUCCESS = { type: 'FETCH_CHAIN_SUCCESS' } as const
const FAILURE = { type: 'FETCH_CHAIN_ERROR' } as const

export function fetchChain (serviceId: string): RSAAAction {
  return {
    [RSAA]: {
      endpoint: `/admin/api/services/${serviceId}/proxy/policies.json`,
      method: 'GET',
      credentials: 'same-origin',
      types: [REQUEST, SUCCESS, FAILURE]
    }
  }
}
