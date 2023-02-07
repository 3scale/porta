import type { State } from 'Policies/types'
import type { PromiseAction, ThunkAction } from 'Policies/types/Actions'
import type { Action, Store as ReduxStore } from 'redux'
import type { RSAAAction } from 'redux-api-middleware'

export type GetState = () => State

export type Dispatch = (action: Action | PromiseAction | RSAAAction | ThunkAction) => Action | PromiseAction | RSAAAction | ThunkAction
export type Store = ReduxStore<State, Action>

export * from 'Policies/types/Actions'
export * from 'Policies/types/Policies'
export * from 'Policies/types/State'
