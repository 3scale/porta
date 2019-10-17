// @flow

import type {
  AddPolicyToChainAction,
  RemovePolicyFromChainAction,
  SortPolicyChainAction,
  UpdatePolicyInChainAction,
  FetchChainErrorAction,
  LoadChainAction,
  LoadChainSuccessAction,
  LoadChainErrorAction,
  UpdatePolicyChainAction
} from 'Policies/actions/PolicyChain'
import type { SetOriginalPolicyChainAction } from 'Policies/actions/OriginalPolicyChain'
import type { UIComponentTransitionAction } from 'Policies/actions/UISettings'
import type {
  FetchRegistrySuccessAction,
  FetchRegistryErrorAction,
  LoadRegistrySuccessAction
} from 'Policies/actions/PolicyRegistry'
import type { UpdatePolicyConfigAction } from 'Policies/actions/PolicyConfig'
import type { Dispatch, GetState, RawRegistry, RegistryPolicy, ChainPolicy, StoredChainPolicy } from 'Policies/types'

export interface IAction {
  type: string
}

type PolicyChainAction = AddPolicyToChainAction | SortPolicyChainAction | LoadChainSuccessAction | LoadChainErrorAction | UpdatePolicyChainAction
type PolicyRegistryAction = FetchRegistrySuccessAction | FetchRegistryErrorAction | LoadRegistrySuccessAction
type PolicyConfigAction = UpdatePolicyConfigAction

export type ThunkAction = (dispatch: Dispatch, getState: GetState) => void
export type PolicyChainMiddlewareAction = UpdatePolicyInChainAction | RemovePolicyFromChainAction | LoadChainAction
export type Action = PolicyConfigAction | PolicyRegistryAction | PolicyChainAction | UIComponentTransitionAction | PolicyChainMiddlewareAction | SetOriginalPolicyChainAction

export interface IPoliciesActions {
  openPolicyRegistry: () => ThunkAction,
  editPolicy: ChainPolicy => ThunkAction,
  sortPolicyChain: Array<ChainPolicy> => SortPolicyChainAction,
  submitPolicyConfig: (ChainPolicy) => ThunkAction,
  removePolicyFromChain: (ChainPolicy) => ThunkAction,
  closePolicyConfig: () => ThunkAction,
  addPolicy: RegistryPolicy => ThunkAction,
  closePolicyRegistry: () => ThunkAction,
  populatePolicies: (serviceId: string, chain?: Array<StoredChainPolicy>, registry?: RawRegistry) => ThunkAction,
  updatePolicyConfig: (ChainPolicy) => UpdatePolicyConfigAction
}

export type RSSAAction = {
  [string]: {
    endpoint: string,
    method: string,
    credentials: string,
    types: []
  }
}

export type FetchErrorAction = FetchChainErrorAction | FetchRegistryErrorAction
export type PromiseAction = Promise<Action>
