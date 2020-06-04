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

const defaultPagination: PaginationState = {
  page: 1,
  perPage: 10,
  startIdx: 0,
  endIdx: 10
}

// Action Handlers
const SET_PAGINATION = 'SET_PAGINATION'

type SetPaginationAction = Action<PaginationState>

const paginationActionHandlers: ActionHandlers<PaginationState, PaginationState> = {
  [SET_PAGINATION]: (state, action: SetPaginationAction) => ({ ...state, ...action.payload })
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
  resetPagination: () => dispatch({ type: SET_PAGINATION, payload: defaultPagination }),
  setPagination: (pagination: PaginationState) => (
    dispatch({ type: SET_PAGINATION, payload: pagination })
  )
})

export { paginationReducer, usePagination, defaultPagination }
