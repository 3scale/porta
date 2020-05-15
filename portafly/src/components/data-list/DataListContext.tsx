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

const initialState: State = {
  table: {
    initialRows: [],
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

const DataListContext = createContext<IDataListContext>({ state: initialState, dispatch: () => {} })

type Props = {
  data: {
    columns: DataListCol[]
    rows: DataListRow[]
  }
}

const DataListProvider: React.FunctionComponent<Props> = ({ data, children }) => {
  const { columns, rows } = data

  const [state, dispatch] = useReducer(combineReducers({
    table: tableReducer,
    filters: filtersReducer,
    pagination: paginationReducer
  }), {
    ...initialState,
    table: {
      initialRows: rows,
      rows,
      columns
    }
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
