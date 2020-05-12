import React from 'react'
import {
  ActionHandlers,
  Action,
  createReducer
} from 'utils'

export type PaginationState = {
  page: number
  perPage: number
  startIdx?: number
  endIdx?: number
}

// Action Handlers
const paginationActionHandlers: ActionHandlers<PaginationState, PaginationState> = {
  SET_PAGINATION: (state, action) => ({ ...state, ...action.payload })
}

// Reducer
const paginationReducer = createReducer(paginationActionHandlers)

// Hook
interface IUsePagination {
  state: Record<'pagination', PaginationState>
  dispatch: React.Dispatch<Action<PaginationState>>
}

const usePagination = ({ state, dispatch }: IUsePagination) => ({
  page: state.pagination.page,
  perPage: state.pagination.perPage,
  startIdx: state.pagination.startIdx,
  endIdx: state.pagination.endIdx,
  setPagination: (pagination: PaginationState) => dispatch({ type: 'SET_PAGINATION', payload: pagination })
})

export { paginationReducer, usePagination }
