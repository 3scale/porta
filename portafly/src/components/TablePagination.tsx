import React, { FunctionComponent, useState } from 'react'
import { Pagination } from '@patternfly/react-core'

interface IPagination {
  perPage?: number
  itemCount: number
  isCompact: boolean
}

const perPageOptions = [
  { title: '5', value: 5 },
  { title: '20', value: 20 },
  { title: '50', value: 50 }
]

const TablePagination: FunctionComponent<IPagination> = ({
  perPage = perPageOptions[0].value,
  itemCount,
  isCompact
}) => {
  const [page] = useState(0)
  return (
    <Pagination
      itemCount={itemCount}
      perPage={perPage}
      page={page}
      onSetPage={() => {}}
      onPerPageSelect={() => {}}
      perPageOptions={perPageOptions}
      isCompact={isCompact}
    />
  )
}

type PaginationState = {
  page: number
  perPage: number
  startIdx?: number
  endIdx?: number
}

type PaginationAction = {
  type: 'setPage' | 'setPerPage'
  payload: Partial<PaginationState>
}

export { TablePagination }
