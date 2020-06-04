import React from 'react'
import {
  ActionHandlers,
  Action,
  createReducer
} from 'utils'
import { Filters } from 'types/data-list'

export type FiltersState = Filters

// Action Handlers
const SET_FILTERS = 'SET_FILTERS'

type SetFiltersAction = Action<Filters>

const filtersActionHandlers: ActionHandlers<FiltersState, Filters> = {
  [SET_FILTERS]: (state, action: SetFiltersAction) => action.payload
}

// Reducer
const filtersReducer = createReducer(filtersActionHandlers)

// Hook
interface IUseFilters {
  state: Record<'filters', FiltersState>
  dispatch: React.Dispatch<Action<Filters>>
}
const useFilters = ({ state, dispatch }: IUseFilters) => ({
  filters: state.filters,
  setFilters: (filters: Filters) => dispatch({ type: SET_FILTERS, payload: filters })
})

export { filtersReducer, useFilters }
