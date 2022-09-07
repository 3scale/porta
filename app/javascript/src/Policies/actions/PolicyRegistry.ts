import {RSAA} from 'redux-api-middleware';

import type { RSSAAction, RegistryPolicy } from 'Policies/types'

export type FetchRegistrySuccessAction = {
  type: 'FETCH_REGISTRY_SUCCESS',
  payload: Array<RegistryPolicy>,
  meta: Record<any, any> | null | undefined
};
export type FetchRegistryErrorAction = {
  type: 'FETCH_REGISTRY_ERROR',
  payload: Record<any, any>,
  error: boolean,
  meta: Record<any, any> | null | undefined
};

const REQUEST = { type: 'FETCH_REGISTRY_REQUEST' } as const
const SUCCESS = { type: 'FETCH_REGISTRY_SUCCESS' } as const
const FAILURE = { type: 'FETCH_REGISTRY_ERROR' } as const

export type LoadRegistrySuccessAction = {
  type: string,
  payload: Array<RegistryPolicy>
};
export function loadRegistrySuccess(payload: Array<RegistryPolicy>): LoadRegistrySuccessAction {
  return { type: 'LOAD_REGISTRY_SUCCESS', payload }
}

export function fetchRegistry(): RSSAAction {
  return {
    [RSAA]: {
      endpoint: '/admin/api/policies.json',
      method: 'GET',
      credentials: 'same-origin',
      types: [REQUEST, SUCCESS, FAILURE]
    }
  }
}
