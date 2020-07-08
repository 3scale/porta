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
  TableState,
  useBulkActions,
  defaultBulkActions,
  BulkActionsState,
  bulkActionsReducer,
  useData,
  DataState,
  dataReducer
} from 'components/shared/data-list/reducers'

export type State = {
  data: DataState
  table: TableState
  filters: FiltersState
  pagination: PaginationState
  bulkActions: BulkActionsState
}

const defaultState: State = {
  data: [],
  // TODO: We should not store the table in our state, we should construct it out from data.
  table: {
    rows: [],
    columns: []
  },
  filters: {},
  pagination: defaultPagination,
  bulkActions: defaultBulkActions
}

export interface IDataListContext {
  state: State,
  dispatch: React.Dispatch<Action<any>>
}

const DataListContext = createContext<IDataListContext>({ state: defaultState, dispatch: () => {} })

type Props = {
  initialState: Partial<State>
}

const DataListProvider: React.FunctionComponent<Props> = ({ initialState, children }) => {
  const [state, dispatch] = useReducer(combineReducers({
    data: dataReducer,
    table: tableReducer,
    filters: filtersReducer,
    pagination: paginationReducer,
    bulkActions: bulkActionsReducer
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
const useDataListBulkActions = () => useBulkActions(useContext(DataListContext))
const useDataListData = () => useData(useContext(DataListContext))

export {
  DataListProvider,
  useDataListTable,
  useDataListFilters,
  useDataListPagination,
  useDataListBulkActions,
  useDataListData
}
