// @flow

import { RSAA } from 'redux-api-middleware'
import type { RSSAAction } from 'types/index'
import type { RawRegistry } from 'types/Policies'

export type FetchRegistrySuccessAction = { type: 'FETCH_REGISTRY_SUCCESS', payload: RawRegistry, meta: ?{} }
export type FetchRegistryErrorAction = { type: 'FETCH_REGISTRY_ERROR', payload: Object, error: boolean, meta: ?{} }

const REQUEST = { type: 'FETCH_REGISTRY_REQUEST' }
const SUCCESS = { type: 'FETCH_REGISTRY_SUCCESS' }
const FAILURE = { type: 'FETCH_REGISTRY_ERROR' }

export type LoadRegistrySuccessAction = { type: string, payload: RawRegistry}
export function loadRegistrySuccess (payload: RawRegistry): LoadRegistrySuccessAction {
  return { type: 'LOAD_REGISTRY_SUCCESS', payload }
}

export function fetchRegistry (): RSSAAction {
  return {
    [RSAA]: {
      endpoint: '/admin/api/policies.json',
      method: 'GET',
      credentials: 'same-origin',
      types: [REQUEST, SUCCESS, FAILURE]
    }
  }
}
