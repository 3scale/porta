import { RSAA } from 'redux-api-middleware'

import type { RSAAAction } from 'redux-api-middleware'
import type { Action } from 'redux'
import type { RegistryPolicy } from 'Policies/types'

export type FetchRegistrySuccessAction = Action<'FETCH_REGISTRY_SUCCESS'> & {
  payload: RegistryPolicy[];
  meta: Record<string, unknown> | null | undefined;
}
export type FetchRegistryErrorAction = Action<'FETCH_REGISTRY_ERROR'> & {
  payload: Record<string, unknown>;
  error: boolean;
  meta: Record<string, unknown> | null | undefined;
}

const REQUEST = { type: 'FETCH_REGISTRY_REQUEST' } as const
const SUCCESS = { type: 'FETCH_REGISTRY_SUCCESS' } as const
const FAILURE = { type: 'FETCH_REGISTRY_ERROR' } as const

export type LoadRegistrySuccessAction = Action<'LOAD_REGISTRY_SUCCESS'> & {
  payload: RegistryPolicy[];
}
export function loadRegistrySuccess (payload: RegistryPolicy[]): LoadRegistrySuccessAction {
  return { type: 'LOAD_REGISTRY_SUCCESS', payload }
}

export function fetchRegistry (): RSAAAction {
  return {
    [RSAA]: {
      endpoint: '/admin/api/policies.json',
      method: 'GET',
      credentials: 'same-origin',
      types: [REQUEST, SUCCESS, FAILURE]
    }
  }
}
