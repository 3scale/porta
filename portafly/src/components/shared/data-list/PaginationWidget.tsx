import React, { FunctionComponent, useMemo } from 'react'
import { Pagination, OnSetPage, OnPerPageSelect } from '@patternfly/react-core'
import { useDataListPagination } from 'components'

interface IPagination {
  itemCount: number
}

const perPageOptions = [
  { title: '5', value: 5 },
  { title: '10', value: 10 },
  { title: '20', value: 20 },
  { title: '30', value: 30 }
]

const PaginationWidget: FunctionComponent<IPagination> = ({ itemCount }) => {
  const { page, perPage, setPagination } = useDataListPagination()

  // FIXME: onSetPage and onPerPageSelect are too similar
  const onSetPage: OnSetPage = (ev, newPage, _perPage, startIdx, endIdx) => {
    setPagination({
      page: newPage,
      perPage: _perPage as number,
      startIdx,
      endIdx
    })
  }

  const onPerPageSelect: OnPerPageSelect = (ev, newPerPage, newPage, startIdx, endIdx) => {
    setPagination({
      page: newPage,
      perPage: newPerPage as number,
      startIdx,
      endIdx
    })
  }

  const isCompact = useMemo(() => (itemCount / perPage) < 3, [itemCount, perPage])

  return (
    <Pagination
      itemCount={itemCount}
      perPage={perPage}
      page={page}
      onSetPage={onSetPage}
      onPerPageSelect={onPerPageSelect}
      perPageOptions={perPageOptions}
      isCompact={isCompact}
    />
  )
}

export { PaginationWidget }
