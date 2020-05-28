import React from 'react'
import {
  ActionHandlers,
  Action,
  createReducer
} from 'utils'

export type FiltersState = Record<string, string[]>

// Action Handlers
const SET_FILTERS = 'SET_FILTERS'

type SetFiltersAction = Action<FiltersState>

const filtersActionHandlers: ActionHandlers<FiltersState, FiltersState> = {
  [SET_FILTERS]: (state, action: SetFiltersAction) => (action.payload as FiltersState)
}

// Reducer
const filtersReducer = createReducer(filtersActionHandlers)

// Hook
interface IUseFilters {
  state: Record<'filters', FiltersState>
  dispatch: React.Dispatch<Action<FiltersState>>
}
const useFilters = ({ state, dispatch }: IUseFilters) => ({
  filters: state.filters,
  setFilters: (filters: FiltersState) => dispatch({ type: SET_FILTERS, payload: filters })
})

export { filtersReducer, useFilters }
