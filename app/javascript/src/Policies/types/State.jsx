// @flow

import type { RegistryPolicy, ChainPolicy } from 'Policies/types/Policies'

export type UIState = {
  +registry: boolean,
  +chain: boolean,
  +policyConfig: boolean,
  +requests: number,
  +submitButtonEnabled: boolean,
  +error: {}
}

export type RegistryState = Array<RegistryPolicy>
export type ChainState = Array<ChainPolicy>

export type State = {
  +registry: RegistryState,
  +chain: ChainState,
  +originalChain: ChainState,
  +policyConfig: ChainPolicy,
  +ui: UIState
}

export type StateSlice = RegistryState | ChainPolicy | ChainState | UIState
