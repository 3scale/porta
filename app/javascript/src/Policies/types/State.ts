import type { ChainPolicy, RegistryPolicy } from 'Policies/types'

export interface UIState {
  readonly registry: boolean;
  readonly chain: boolean;
  readonly policyConfig: boolean;
  readonly requests: number;
  readonly submitButtonEnabled: boolean;
  readonly error: Record<string, unknown>;
}

export interface State {
  readonly registry: RegistryPolicy[];
  readonly chain: ChainPolicy[];
  readonly originalChain: ChainPolicy[];
  readonly policyConfig: ChainPolicy;
  readonly ui: UIState;
}

export type StateSlice = ChainPolicy | ChainPolicy[] | RegistryPolicy[] | UIState
