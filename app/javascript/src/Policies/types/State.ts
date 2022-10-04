import type { ChainPolicy, RegistryPolicy } from 'Policies/types'

export type UIState = {
  readonly registry: boolean,
  readonly chain: boolean,
  readonly policyConfig: boolean,
  readonly requests: number,
  readonly submitButtonEnabled: boolean,
  readonly error: Record<any, any>
}

export type State = {
  readonly registry: RegistryPolicy[],
  readonly chain: ChainPolicy[],
  readonly originalChain: ChainPolicy[],
  readonly policyConfig: ChainPolicy,
  readonly ui: UIState
}

export type StateSlice = RegistryPolicy[] | ChainPolicy | ChainPolicy[] | UIState
