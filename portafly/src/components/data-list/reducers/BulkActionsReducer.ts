import React from 'react'
import {
  ActionHandlers,
  Action,
  createReducer
} from 'utils'

export type BulkAction = 'sendEmail' | 'changeState' | undefined
export type BulkActionsState = {
  modal: BulkAction,
  isLoading: boolean,
  errorMsg?: string
}

const defaultBulkActions: BulkActionsState = {
  modal: undefined,
  isLoading: false,
  errorMsg: undefined
}

// Action Handlers
const SET_MODAL = 'SET_MODAL'
const CLOSE_MODAL = 'CLOSE_MODAL'
const ACTION_START = 'ACTION_START'
const ACTION_SUCCESS = 'ACTION_SUCCESS'
const ACTION_FAILED = 'ACTION_FAILED'

type SetModalAction = Action<BulkAction>
type ActionFailedAction = Action<string>

const BulkActionsActionHandlers: ActionHandlers<BulkActionsState, any> = {
  [SET_MODAL]: (state, action: SetModalAction) => ({ ...state, modal: action.payload }),
  [CLOSE_MODAL]: (state) => ({ ...state, modal: undefined, errorMsg: undefined }),
  [ACTION_START]: (state) => ({ ...state, isLoading: true }),
  [ACTION_SUCCESS]: () => defaultBulkActions,
  [ACTION_FAILED]: (state, action: ActionFailedAction) => (
    { ...state, isLoading: false, errorMsg: action.payload }
  )
}

// Reducer
const bulkActionsReducer = createReducer(BulkActionsActionHandlers)

// Hook
interface IUseBulkActions {
  state: Record<'bulkActions', BulkActionsState>
  dispatch: React.Dispatch<Action<any>>
}
const useBulkActions = ({ state, dispatch }: IUseBulkActions) => ({
  modal: state.bulkActions.modal,
  isLoading: state.bulkActions.isLoading,
  errorMsg: state.bulkActions.errorMsg,
  setModal: (modal: BulkAction) => dispatch({ type: SET_MODAL, payload: modal }),
  closeModal: () => dispatch({ type: CLOSE_MODAL, payload: undefined }),
  actionStart: () => dispatch({ type: ACTION_START, payload: undefined }),
  actionSuccess: () => dispatch({ type: ACTION_SUCCESS, payload: undefined }),
  actionFailed: (errorMsg: string) => dispatch({ type: ACTION_FAILED, payload: errorMsg })
})

export { bulkActionsReducer, useBulkActions, defaultBulkActions }
