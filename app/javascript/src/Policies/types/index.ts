import type {
  State,
  IPoliciesActions,
  IAction,
  Action,
  ThunkAction,
  PromiseAction,
  RSSAAction,
} from 'Policies/types';

export type GetState = () => State;

export type Dispatch = (action: Action | ThunkAction | PromiseAction | RSSAAction) => Action | ThunkAction | PromiseAction | RSSAAction;

export type Reducer<S> = (state: S, action: IAction) => S;

export type Store = State & {
  boundActionCreators: IPoliciesActions,
  dispatch: Dispatch
};

export * from 'Policies/types/Actions';
export * from 'Policies/types/Policies';
export * from 'Policies/types/State';
