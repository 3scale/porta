import { Pagination as PFPagination } from '@patternfly/react-core'

import type { PaginationProps, OnPerPageSelect } from '@patternfly/react-core'
import type { FunctionComponent, ReactElement } from 'react'

type Props = Pick<PaginationProps, 'itemCount' | 'variant'>

const Pagination: FunctionComponent<Props> = ({ variant, itemCount }): ReactElement<PaginationProps> => {
  const url = new URL(window.location.href)
  const currentPage = Number(url.searchParams.get('page'))
  const currentPerPage = Number(url.searchParams.get('per_page')) || 20

  const onPerPageSelect: OnPerPageSelect = (_event, selectedPerPage) => {
    url.searchParams.set('per_page', String(selectedPerPage))
    url.searchParams.delete('page')
    window.location.replace(url.toString())
  }

  const goToPage = (_ev: unknown, page: number) => {
    url.searchParams.set('page', String(page))
    window.location.replace(url.toString())
  }

  return (
    <PFPagination
      itemCount={itemCount}
      page={currentPage}
      perPage={currentPerPage}
      perPageOptions={[{ title: '10', value: 10 }, { title: '20', value: 20 }]}
      variant={variant}
      widgetId="pagination-options-menu-top"
      onFirstClick={goToPage}
      onLastClick={goToPage}
      onNextClick={goToPage}
      onPerPageSelect={onPerPageSelect}
      onPreviousClick={goToPage}
    />
  )
}

export { Pagination }
