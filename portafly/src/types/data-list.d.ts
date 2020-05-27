import { IRow, ICell } from '@patternfly/react-table'

export type DataListRow = IRow & { cells: (React.ReactNode | IRowCell)[], id: number }
export type DataListCol = ICell
