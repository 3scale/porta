import { Pagination as PFPagination } from '@patternfly/react-core'

import type { PaginationProps, OnPerPageSelect } from '@patternfly/react-core'
import type { FunctionComponent } from 'react'

type Props = Pick<PaginationProps, 'itemCount' | 'variant'>

const Pagination: FunctionComponent<Props> = ({ variant, itemCount }) => {
  const url = new URL(window.location.href)
  const currentPage = Number(url.searchParams.get('page') ?? 1)
  const currentPerPage = Number(url.searchParams.get('per_page') ?? 20)

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
      perPageComponent="button"
      perPageOptions={[{ title: '10', value: 10 }, { title: '20', value: 20 }]}
      variant={variant}
      widgetId="pagination-options-menu-top"
      onFirstClick={goToPage}
      onLastClick={goToPage}
      onNextClick={goToPage}
      onPageInput={goToPage}
      onPerPageSelect={onPerPageSelect}
      onPreviousClick={goToPage}
    />
  )
}

export type { Props }
export { Pagination }
