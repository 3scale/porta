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
const BulkActionsActionHandlers: ActionHandlers<BulkActionsState, any> = {
  SET_MODAL: (state, action: Action<BulkAction>) => ({ ...state, modal: action.payload }),
  CLOSE_MODAL: (state) => ({ ...state, modal: undefined, errorMsg: undefined }),
  ACTION_START: (state) => ({ ...state, isLoading: true }),
  ACTION_SUCCESS: () => defaultBulkActions,
  ACTION_FAILED: (state, action: Action<string>) => (
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
  setModal: (modal: BulkAction) => dispatch({ type: 'SET_MODAL', payload: modal }),
  closeModal: () => dispatch({ type: 'CLOSE_MODAL', payload: undefined }),
  actionStart: () => dispatch({ type: 'ACTION_START', payload: undefined }),
  actionSuccess: () => dispatch({ type: 'ACTION_SUCCESS', payload: undefined }),
  actionFailed: (errorMsg: string) => dispatch({ type: 'ACTION_FAILED', payload: errorMsg })
})

export { bulkActionsReducer, useBulkActions, defaultBulkActions }
