import React from 'react'
import {
  ActionHandlers,
  Action,
  createReducer
} from 'utils'

export type BulkAction = 'sendEmail' | 'changeState' | undefined
export type BulkActionsState = {
  modal: BulkAction,
  isLoading: boolean
}

// Action Handlers
const BulkActionsActionHandlers: ActionHandlers<BulkActionsState, BulkAction> = {
  SET_MODAL: (state, action: Action<BulkAction>) => ({ ...state, modal: action.payload }),
  ACTION_START: (state) => ({ ...state, isLoading: true }),
  ACTION_SUCCESS: (state) => ({ ...state, isLoading: false, modal: undefined }),
  ACTION_FAILED: (state) => ({ ...state, isLoading: false })
}

// Reducer
const bulkActionsReducer = createReducer(BulkActionsActionHandlers)

// Hook
interface IUseBulkActions {
  state: Record<'bulkActions', BulkActionsState>
  dispatch: React.Dispatch<Action<BulkAction>>
}
const useBulkActions = ({ state, dispatch }: IUseBulkActions) => ({
  modal: state.bulkActions.modal,
  isLoading: state.bulkActions.isLoading,
  setModal: (modal: BulkAction) => dispatch({ type: 'SET_MODAL', payload: modal }),
  actionStart: () => dispatch({ type: 'ACTION_START', payload: undefined }),
  actionSuccess: () => dispatch({ type: 'ACTION_SUCCESS', payload: undefined }),
  actionFailed: () => dispatch({ type: 'ACTION_FAILED', payload: undefined })
})

export { bulkActionsReducer, useBulkActions }
