import { DataListRow, DataListCol, Filters } from 'types/data-list'

export function filterRows(
  rows: DataListRow[],
  filters: Filters,
  columns: DataListCol[]
) {
  let newRows = [...rows]

  Object.keys(filters).forEach((categoryName) => {
    if (newRows.length === 0 || filters[categoryName].length === 0) {
      return
    }

    const colIdx = columns.findIndex((c) => c.categoryName === categoryName)

    if (colIdx === -1) {
      console.warn('Category "%s" doesn\'t correspond to any column in your DataList', categoryName)
      return
    }

    newRows = newRows.filter((r) => {
      const value = (r.cells)[colIdx].toLowerCase()
      return filters[categoryName].some((f) => value.indexOf(f.toLowerCase()) > -1)
    })
  })

  return newRows
}
