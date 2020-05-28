import { DataListRow, DataListCol, Filters } from 'types/data-list'

const getFilterCallbackFn = (colIdx: number, terms: string[]) => (r: DataListRow) => {
  const value = (r.cells)[colIdx].toLowerCase()
  return terms.some((f) => value.indexOf(f.toLowerCase()) > -1)
}

/**
 * Returns a new array with the provided rows filtered.
 * @param rows DataListRow[] - The rows to be filtered
 * @param filters Filters - An object containing different categories and filtering terms
 * @param columns DataListCol[] - The columns of the Table being filtered
 */
export function filterRows(
  rows: DataListRow[],
  filters: Filters,
  columns: DataListCol[]
) {
  if (rows.length === 0) {
    return []
  }

  let newRows = [...rows]

  Object.keys(filters).forEach((categoryName) => {
    // Check category is valid
    const colIdx = columns.findIndex((c) => c.categoryName === categoryName)

    if (colIdx === -1) {
      console.warn('Category "%s" doesn\'t exist in your DataList', categoryName)
      return
    }

    // Check there are terms
    const termsForCategory = filters[categoryName]

    if (termsForCategory.length) {
      const filterRowForCategory = getFilterCallbackFn(colIdx, termsForCategory)
      newRows = newRows.filter(filterRowForCategory)
    }
  })

  return newRows
}
