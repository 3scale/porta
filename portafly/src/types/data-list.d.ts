import { IRow, ICell } from '@patternfly/react-table'

export type DataListRow = IRow & { cells: (React.ReactNode | IRowCell)[], id: number }
export type DataListCol = ICell & { categoryName: string }
export type CategoryOption = {
  name: string
  humanName: string
}
export type Category = {
  name: string
  humanName: string
  options?: CategoryOption[]
}
export type Filters = Record<string, string[]>
