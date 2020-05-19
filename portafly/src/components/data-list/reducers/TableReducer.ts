import React from 'react'
import {
  ActionHandlers,
  Action,
  createReducer
} from 'utils'
import { DataListRow, DataListCol } from 'types'

export type TableState = {
  rows: DataListRow[]
  columns: DataListCol[]
}

// Action Handlers
const SELECT_ONE = 'SELECT_ONE'
const SELECT_PAGE = 'SELECT_PAGE'
const SELECT_ALL = 'SELECT_ALL'

const tableActionHandlers: ActionHandlers<TableState, any> = {
  [SELECT_ONE]: (state, action: Action<{ id: number, selected: boolean }>) => {
    const { id, selected } = action.payload
    const newRows = state.rows.map((r) => (r.id === id ? { ...r, selected } : r))
    return { ...state, rows: newRows }
  },
  [SELECT_PAGE]: (state, action: Action<DataListRow[]>) => {
    const visibleRows = action.payload
    const newRows = state.rows.map((r) => ({
      ...r,
      selected: visibleRows.some((vR) => vR.id === r.id)
    }))

    return { ...state, rows: newRows }
  },
  [SELECT_ALL]: (state, action: Action<{ selected: boolean, filteredRows?: DataListRow[] }>) => {
    const { selected, filteredRows } = action.payload
    const { rows } = state

    const shouldAffectAllRows = !selected || !filteredRows || filteredRows.length === rows.length

    const newRows = shouldAffectAllRows
      ? rows.map((r) => ({ ...r, selected }))
      : rows.map((r) => ({
        ...r,
        selected: (filteredRows as DataListRow[]).some((fR) => fR.id === r.id)
      }))

    return { ...state, rows: newRows }
  }
}

// Reducer
const tableReducer = createReducer(tableActionHandlers)

// Hook
interface IUseTable {
  state: Record<'table', TableState>
  dispatch: React.Dispatch<Action<any>>
}

const useTable = ({ state, dispatch }: IUseTable) => ({
  columns: state.table.columns,
  rows: state.table.rows,
  selectedRows: state.table.rows.filter((r) => Boolean(r.selected)),
  selectOne: (id: number, selected: boolean) => (
    dispatch({ type: SELECT_ONE, payload: { id, selected } })
  ),
  selectPage: (visibleRows: DataListRow[]) => (
    dispatch({ type: SELECT_PAGE, payload: visibleRows })
  ),
  selectAll: (selected: boolean, filteredRows?: DataListRow[]) => (
    dispatch({ type: SELECT_ALL, payload: { selected, filteredRows } })
  )
})

export { tableReducer, useTable }
