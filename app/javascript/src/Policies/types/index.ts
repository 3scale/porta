import type { State } from 'Policies/types'
import type { PromiseAction, ThunkAction } from 'Policies/types/Actions'
import type { Action, Store as ReduxStore } from 'redux'
import type { RSAAAction } from 'redux-api-middleware'

export type GetState = () => State

export type Dispatch = (action: Action | ThunkAction | PromiseAction | RSAAAction) => Action | ThunkAction | PromiseAction | RSAAAction
export type Store = ReduxStore<State, Action<any>>

export * from 'Policies/types/Actions'
export * from 'Policies/types/Policies'
export * from 'Policies/types/State'
