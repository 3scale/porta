// @flow

import type { State } from 'Policies/types/State'
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
import type { UIComponentTransitionAction } from 'Policies/actions/UISettings'
import type {
  FetchRegistrySuccessAction,
  FetchRegistryErrorAction,
  LoadRegistrySuccessAction
} from 'Policies/actions/PolicyRegistry'
import type { UpdatePolicyConfigAction } from 'Policies/actions/PolicyConfig'

type PolicyChainAction = AddPolicyToChainAction | SortPolicyChainAction
  | LoadChainSuccessAction | LoadChainErrorAction | UpdatePolicyChainAction

type PolicyRegistryAction = FetchRegistrySuccessAction
  | FetchRegistryErrorAction | LoadRegistrySuccessAction

type PolicyConfigAction = UpdatePolicyConfigAction

export type RSSAAction = {
  [string]: {
    endpoint: string,
    method: string,
    credentials: string,
    types: []
  }
}

export type PolicyChainMiddlewareAction = UpdatePolicyInChainAction
  | RemovePolicyFromChainAction | LoadChainAction
export type FetchErrorAction = FetchChainErrorAction | FetchRegistryErrorAction
// Actions
export interface IAction {
  type: string
}

export type Action = PolicyConfigAction | PolicyRegistryAction
  | PolicyChainAction | UIComponentTransitionAction | PolicyChainMiddlewareAction

export type Dispatch = (action: Action | ThunkAction | PromiseAction | RSSAAction) => any
export type GetState = () => State
export type ThunkAction = (dispatch: Dispatch, getState: GetState) => any
export type PromiseAction = Promise<Action>

export type Reducer<S> = (state?: S, action: IAction) => S
