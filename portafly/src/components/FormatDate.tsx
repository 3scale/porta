import * as React from 'react'
import { format } from 'date-fns'
import { ArgumentsType } from 'types'

// TODO: Fix component to use TZ
export interface IFormatDateProps {
  date: string | Date | number
  format?: string
  options?: ArgumentsType<typeof format>[2]
}
export const FormatDate: React.FunctionComponent<IFormatDateProps> = ({
  date,
  format: formatTpl = 'Pp',
  options,
}) => {
  date = typeof date === 'string' ? new Date(date) : date
  return <>{format(date, formatTpl, options)}</>
}
