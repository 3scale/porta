import {
  DataListRow,
  DataListCol,
  Filters,
  DataListRowCell
} from 'types/data-list'

const isTermInRowForColumn = (row: DataListRow, colIdx: number) => (term: string) => {
  const cell = row.cells[colIdx]

  const target = typeof cell === 'object'
    ? (cell as DataListRowCell).stringValue
    : cell

  return target.toLowerCase().indexOf(term.toLowerCase()) > -1
}
/**
 * Filters a DataListRow given a colIdx and filtering terms.
 * @param colIdx number - The index of a categoryName column.
 * @param terms string[] - An array of filtering terms.
 * @returns {(row: DataListRow) => boolean} - fn that takes a DataListRow and returns boolean
 */
const filterRowByTerm = (colIdx: number, terms: string[]) => (row: DataListRow): boolean => (
  terms.length
    ? terms.some(isTermInRowForColumn(row, colIdx))
    : true
)

/**
 * Finds the index of a DataListCol.
 * @param columns DataListCol[] - An array of DataListCol.
 * @returns {(categoryName: string) => number} - fn that takes a categoryName and returns its index.
 */
const findColIdx = (columns: DataListCol[]) => (categoryName: string): number => {
  const index = columns.findIndex((c) => c.categoryName === categoryName)
  // TODO: In the future we could show the error in a toast. Event driven approach maybe.
  if (index === -1) throw new Error('You are trying to filter a category that doesn\'t correspond to any column in your DataList')
  return index
}

/**
 * Returns a new array with the provided rows filtered.
 * @param rows DataListRow[] - The rows to be filtered
 * @param filters Filters - An object containing different categories and filtering terms
 * @param columns DataListCol[] - The columns of the Table being filtered
 * @returns DataListRow[] - The given rows filtered.
 */

const filterRows = (
  rows: DataListRow[],
  filters: Filters,
  columns: DataListCol[]
): DataListRow[] => (
  Object.keys(filters).reduce((filteredRows, categoryName) => (
    filteredRows.filter(
      filterRowByTerm(
        findColIdx(columns)(categoryName),
        filters[categoryName]
      )
    )
  ), rows)
)

export { filterRows }
