import React, { createContext, useContext, useReducer } from 'react'
import { combineReducers, Action } from 'utils'
import {
  filtersReducer,
  paginationReducer,
  useFilters,
  usePagination,
  FiltersState,
  PaginationState
} from 'components/data-list/reducers'

type State = {
  filters: FiltersState
  pagination: PaginationState
}
const initialState: State = {
  filters: {},
  pagination: {
    page: 1,
    perPage: 10,
    startIdx: 0,
    endIdx: 10
  }
}

export interface IDataListContext {
  state: State,
  dispatch: React.Dispatch<Action<any>>
}

const DataListContext = createContext<IDataListContext>({ state: initialState, dispatch: () => {} })

const DataListProvider: React.FunctionComponent = ({ children }) => {
  const [state, dispatch] = useReducer(combineReducers({
    filters: filtersReducer,
    pagination: paginationReducer
  }), initialState)
  return (
    <DataListContext.Provider
      value={{ state, dispatch } as IDataListContext}
    >
      {children}
    </DataListContext.Provider>
  )
}

const useDataListFilters = () => useFilters(useContext(DataListContext))
const useDataListPagination = () => usePagination(useContext(DataListContext))

export {
  DataListProvider,
  useDataListFilters,
  useDataListPagination
}
