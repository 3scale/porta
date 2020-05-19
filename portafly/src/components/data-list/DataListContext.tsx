import React, { createContext, useContext, useReducer } from 'react'
import { combineReducers, Action } from 'utils'
import {
  defaultPagination,
  filtersReducer,
  paginationReducer,
  useFilters,
  usePagination,
  FiltersState,
  PaginationState,
  tableReducer,
  useTable,
  TableState
} from 'components/data-list/reducers'
import { DataListCol, DataListRow } from 'types'

type State = {
  table: TableState,
  filters: FiltersState
  pagination: PaginationState
}

const defaultState: State = {
  table: {
    rows: [],
    columns: []
  },
  filters: {},
  pagination: defaultPagination
}

export interface IDataListContext {
  state: State,
  dispatch: React.Dispatch<Action<any>>
}

const DataListContext = createContext<IDataListContext>({ state: defaultState, dispatch: () => {} })

type Props = {
  initialState: {
    table: {
      columns: DataListCol[]
      rows: DataListRow[]
    }
  }
}

const DataListProvider: React.FunctionComponent<Props> = ({ initialState, children }) => {
  const [state, dispatch] = useReducer(combineReducers({
    table: tableReducer,
    filters: filtersReducer,
    pagination: paginationReducer
  }), {
    ...defaultState,
    ...initialState
  })

  return (
    <DataListContext.Provider
      value={{ state, dispatch } as IDataListContext}
    >
      {children}
    </DataListContext.Provider>
  )
}

const useDataListTable = () => useTable(useContext(DataListContext))
const useDataListFilters = () => useFilters(useContext(DataListContext))
const useDataListPagination = () => usePagination(useContext(DataListContext))

export {
  DataListProvider,
  useDataListTable,
  useDataListFilters,
  useDataListPagination
}
