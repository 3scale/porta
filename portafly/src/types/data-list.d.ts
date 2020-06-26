import { IRow, ICell, IRowCell } from '@patternfly/react-table'
import { TFunction } from 'i18next'

export type DataListRow = Omit<IRow, 'cells'> & { id: number, cells: (DataListRowCell | string)[] }
export type DataListRowCell = IRowCell & { stringValue: string }
export type DataListCol = ICell & { categoryName: string }
export type DataListRowGenerator = (collection: Array) => DataListRow[]
export type DataListColumnGenerator = (t: TFunction) => DataListCol[]
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
