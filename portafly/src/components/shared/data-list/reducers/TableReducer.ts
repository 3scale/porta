import React from 'react'
import {
  ActionHandlers,
  Action,
  createReducer
} from 'utils'
import { DataListRow, DataListCol, DataListRowCell } from 'types'
import { SortByDirection } from '@patternfly/react-table'

export type TableState = {
  rows: DataListRow[]
  columns: DataListCol[]
  sortBy?: {
    index: number
    direction: SortByDirection
  }
}

// Utils
const sorter = (index: number) => (prevRow: DataListRow, nextRow: DataListRow) => {
  const prev = prevRow.cells[index]
  const next = nextRow.cells[index]

  const buildTarget = (cell: string | DataListRowCell) => (typeof cell === 'object'
    ? cell.stringValue.replace(/<[^>]+>/g, '')
    : cell)

  const prevTarget = buildTarget(prev)
  const nextTarget = buildTarget(next)

  if (prevTarget < nextTarget) return -1
  if (prevTarget > nextTarget) return 1
  return 0
}

// Action Handlers
const SET_SORT_BY = 'SET_SORT_BY'
const SELECT_ONE = 'SELECT_ONE'
const SELECT_PAGE = 'SELECT_PAGE'
const SELECT_ALL = 'SELECT_ALL'

type SetSortByAction = Action<{ index: number, direction: SortByDirection, isSelectable?: boolean }>
type SelectOneAction = Action<{ id: number, selected: boolean }>
type SelectPageAction = Action<DataListRow[]>
type SelectAllAction = Action<{ selected: boolean, filteredRows?: DataListRow[] }>

const tableActionHandlers: ActionHandlers<TableState, any> = {
  [SET_SORT_BY]: (state, action: SetSortByAction) => {
    const { index, direction, isSelectable } = action.payload
    const sortedRows = [...state.rows]

    // When table is selectable, index must be corrected because of the first row of checkboxes
    sortedRows.sort(sorter(isSelectable ? (index - 1) : index))

    if (direction === SortByDirection.desc) {
      sortedRows.reverse()
    }

    return { ...state, rows: sortedRows, sortBy: action.payload }
  },
  [SELECT_ONE]: (state, action: SelectOneAction) => {
    const { id, selected } = action.payload
    const newRows = state.rows.map((r) => (r.id === id ? { ...r, selected } : r))
    return { ...state, rows: newRows }
  },
  [SELECT_PAGE]: (state, action: SelectPageAction) => {
    const visibleRows = action.payload
    const newRows = state.rows.map((r) => ({
      ...r,
      selected: visibleRows.some((vR) => vR.id === r.id)
    }))

    return { ...state, rows: newRows }
  },
  [SELECT_ALL]: (state, action: SelectAllAction) => {
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
  sortBy: state.table.sortBy,
  setSortBy: (index: number, direction: SortByDirection, isSelectable?: boolean) => (
    dispatch({ type: SET_SORT_BY, payload: { index, direction, isSelectable } })
  ),
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
