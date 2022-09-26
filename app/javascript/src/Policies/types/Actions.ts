import { ThunkAction as ReduxThunkAction } from 'redux-thunk'
import type {
  AddPolicyToChainAction,
  RemovePolicyFromChainAction,
  SortPolicyChainAction,
  UpdatePolicyInChainAction,
  FetchChainErrorAction,
  LoadChainAction,
  LoadChainSuccessAction,
  LoadChainErrorAction,
  UpdatePolicyChainAction
} from 'Policies/actions/PolicyChain'
import type { SetOriginalPolicyChainAction } from 'Policies/actions/OriginalPolicyChain'
import type { UIComponentTransitionAction } from 'Policies/actions/UISettings'
import type {
  FetchRegistrySuccessAction,
  FetchRegistryErrorAction,
  LoadRegistrySuccessAction
} from 'Policies/actions/PolicyRegistry'
import type { UpdatePolicyConfigAction } from 'Policies/actions/PolicyConfig'
import type { ChainPolicy, PolicyConfig, RegistryPolicy, State } from 'Policies/types'

type PolicyChainAction = AddPolicyToChainAction | SortPolicyChainAction | LoadChainSuccessAction | LoadChainErrorAction | UpdatePolicyChainAction;
type PolicyRegistryAction = FetchRegistrySuccessAction | FetchRegistryErrorAction | LoadRegistrySuccessAction;
type PolicyConfigAction = UpdatePolicyConfigAction;

export type PolicyChainMiddlewareAction = UpdatePolicyInChainAction | RemovePolicyFromChainAction | LoadChainAction;
export type Action = PolicyConfigAction | PolicyRegistryAction | PolicyChainAction | UIComponentTransitionAction | PolicyChainMiddlewareAction | SetOriginalPolicyChainAction;

export type ThunkAction = ReduxThunkAction<void, State, void, Action>

export interface IPoliciesActions {
  openPolicyRegistry: () => ThunkAction;
  closePolicyRegistry: () => ThunkAction;
  openPolicyForm: (arg1: ChainPolicy) => ThunkAction;
  closePolicyForm: () => ThunkAction;
  sortPolicyChain: (arg1: Array<ChainPolicy>) => SortPolicyChainAction;
  submitPolicyForm: (arg1: ChainPolicy) => ThunkAction;
  updatePolicyConfig: (arg1: ChainPolicy) => UpdatePolicyConfigAction;
  removePolicyFromChain: (arg1: ChainPolicy) => ThunkAction;
  addPolicyFromRegistry: (arg1: RegistryPolicy) => ThunkAction;
  populateChainFromConfigs: (
    serviceId: string,
    configs?: Array<PolicyConfig>,
    registry?: Array<RegistryPolicy>,
  ) => ThunkAction;
}

export type FetchErrorAction = FetchChainErrorAction | FetchRegistryErrorAction;
export type PromiseAction = Promise<Action>;
