// @flow
/* eslint-disable no-use-before-define */

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
import type { SetOriginalPolicyChainAction } from 'Policies/actions/OriginalPolicyChain'
import type { UIComponentTransitionAction, EnableSubmitButtonAction } from 'Policies/actions/UISettings'
import type {
  FetchRegistrySuccessAction,
  FetchRegistryErrorAction,
  LoadRegistrySuccessAction
} from 'Policies/actions/PolicyRegistry'
import type { UpdatePolicyConfigAction } from 'Policies/actions/PolicyConfig'
import type { IPoliciesActions } from 'Policies/actions'

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
  | EnableSubmitButtonAction | SetOriginalPolicyChainAction

export type PromiseAction = Promise<Action>
export type GetState = () => State
export type Dispatch = (action: Action | ThunkAction | PromiseAction | RSSAAction) => any
export type ThunkAction = (dispatch: Dispatch, getState: GetState) => any

export type Reducer<S> = (state?: S, action: IAction) => S

export type Store = State & {
  boundActionCreators: IPoliciesActions,
  dispatch: Dispatch
}

export type ElementEventTemplate<E> = {
  target: E
} & Event & SyntheticEvent<>

export type InputEvent = ElementEventTemplate<HTMLInputElement>
