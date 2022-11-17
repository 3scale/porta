import type { ThunkAction as ReduxThunkAction } from 'redux-thunk'
import type {
  AddPolicyToChainAction,
  FetchChainErrorAction,
  LoadChainAction,
  LoadChainErrorAction,
  LoadChainSuccessAction,
  RemovePolicyFromChainAction,
  SortPolicyChainAction,
  UpdatePolicyChainAction,
  UpdatePolicyInChainAction
} from 'Policies/actions/PolicyChain'
import type { SetOriginalPolicyChainAction } from 'Policies/actions/OriginalPolicyChain'
import type { UIComponentTransitionAction } from 'Policies/actions/UISettings'
import type {
  FetchRegistryErrorAction,
  FetchRegistrySuccessAction,
  LoadRegistrySuccessAction
} from 'Policies/actions/PolicyRegistry'
import type { UpdatePolicyConfigAction } from 'Policies/actions/PolicyConfig'
import type { ChainPolicy, PolicyConfig, RegistryPolicy, State } from 'Policies/types'

type PolicyChainAction = AddPolicyToChainAction | LoadChainErrorAction | LoadChainSuccessAction | SortPolicyChainAction | UpdatePolicyChainAction
type PolicyRegistryAction = FetchRegistryErrorAction | FetchRegistrySuccessAction | LoadRegistrySuccessAction
type PolicyConfigAction = UpdatePolicyConfigAction

export type PolicyChainMiddlewareAction = LoadChainAction | RemovePolicyFromChainAction | UpdatePolicyInChainAction
export type Action = PolicyChainAction | PolicyChainMiddlewareAction | PolicyConfigAction | PolicyRegistryAction | SetOriginalPolicyChainAction | UIComponentTransitionAction

export type ThunkAction = ReduxThunkAction<void, State, void, Action>

export interface IPoliciesActions {
  openPolicyRegistry: () => ThunkAction;
  closePolicyRegistry: () => ThunkAction;
  openPolicyForm: (policy: ChainPolicy) => ThunkAction;
  closePolicyForm: () => ThunkAction;
  sortPolicyChain: (policies: ChainPolicy[]) => SortPolicyChainAction;
  submitPolicyForm: (policy: ChainPolicy) => ThunkAction;
  updatePolicyConfig: (policy: ChainPolicy) => UpdatePolicyConfigAction;
  removePolicyFromChain: (policy: ChainPolicy) => ThunkAction;
  addPolicyFromRegistry: (registryPolicy: RegistryPolicy) => ThunkAction;
  populateChainFromConfigs: (
    serviceId: string,
    configs?: PolicyConfig[],
    registry?: RegistryPolicy[],
  ) => ThunkAction;
}

export type FetchErrorAction = FetchChainErrorAction | FetchRegistryErrorAction
export type PromiseAction = Promise<Action>
