import { DataListRow, DataListCol, Filters } from 'types/data-list'

const filterByTerm = (colIdx: number, terms: string[]) => (row: DataListRow): boolean => (
  terms.length
    ? terms.some((f) => (row.cells)[colIdx].toLowerCase().indexOf(f.toLowerCase()) > -1)
    : true
)

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
 */

const filterRows = (
  rows: DataListRow[],
  filters: Filters,
  columns: DataListCol[]
): DataListRow[] => (
  Object.keys(filters).reduce((acc, categoryName) => (
    acc.filter(filterByTerm(findColIdx(columns)(categoryName), filters[categoryName]))
  ), rows)
)

export { filterRows }
