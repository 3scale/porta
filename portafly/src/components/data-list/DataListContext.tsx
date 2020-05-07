import React, { createContext, useContext, useReducer } from 'react'
import { combineReducers, Action } from 'utils'
import {
  filtersReducer,
  useFilters,
  FiltersState
} from 'components/data-list/reducers'

type State = {
  filters: FiltersState
}
const initialState: State = {
  filters: {}
}

export interface IDataListContext {
  state: State,
  dispatch: React.Dispatch<Action<any>>
}

const DataListContext = createContext<IDataListContext>({ state: initialState, dispatch: () => {} })

const DataListProvider: React.FunctionComponent = ({ children }) => {
  const [state, dispatch] = useReducer(combineReducers({ filters: filtersReducer }), initialState)

  return (
    <DataListContext.Provider
      value={{ state, dispatch } as IDataListContext}
    >
      {children}
    </DataListContext.Provider>
  )
}

const useDataListFilters = () => useFilters(useContext(DataListContext))

export { DataListProvider, useDataListFilters }
