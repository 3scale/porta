// @flow

import type { RegistryPolicy, ChainPolicy } from 'Policies/types'

export type UIState = {
  +registry: boolean,
  +chain: boolean,
  +policyConfig: boolean,
  +requests: number,
  +submitButtonEnabled: boolean,
  +error: {}
}

export type State = {
  +registry: RegistryPolicy[],
  +chain: ChainPolicy[],
  +originalChain: ChainPolicy[],
  +policyConfig: ChainPolicy,
  +ui: UIState
}

export type StateSlice = RegistryPolicy[] | ChainPolicy | ChainPolicy[] | UIState
