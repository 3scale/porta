import React, { createContext, useContext, useReducer } from 'react'
import {
  createReducer,
  combineReducers,
  ActionHandlers,
  Action
} from 'utils'

type Filters = Record<string, string[]>

type State = {
  filters: Filters
}

const initialState: State = {
  filters: {}
}

const filtersActions: ActionHandlers = {
  SET_FILTERS: (filters, action) => ({ ...filters, ...action.payload }),
  CLEAR_FILTERS: () => ({})
}

const filtersReducer = createReducer(filtersActions)

interface IDataListContext {
  state: State,
  dispatch: React.Dispatch<Action>
}

const DataListContext = createContext<IDataListContext>({ state: initialState, dispatch: () => {} })

const DataListProvider: React.FunctionComponent = ({ children }) => {
  const [state, dispatch] = useReducer(combineReducers({ filters: filtersReducer }), initialState)

  return (
    <DataListContext.Provider
      value={{ state, dispatch } as { state: State, dispatch: React.Dispatch<Action>}}
    >
      {children}
    </DataListContext.Provider>
  )
}

const useDataList = () => useContext(DataListContext)

const useDataListFilters = () => {
  const { state, dispatch } = useDataList()
  return {
    filters: state.filters,
    setFilters: (filters: Filters) => dispatch({ type: 'SET_FILTERS', payload: filters }),
    clearFilters: () => dispatch({ type: 'CLEAR_FILTERS' })
  }
}

export { DataListProvider, useDataListFilters }
