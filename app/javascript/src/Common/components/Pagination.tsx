import { Pagination as PFPagination } from '@patternfly/react-core'

import type { PaginationProps , OnPerPageSelect } from "@patternfly/react-core"
import type { FunctionComponent, ReactElement } from "react"

type Props = Pick<PaginationProps, 'variant' | 'itemCount'>

const Pagination: FunctionComponent<Props> = ({ variant, itemCount }): ReactElement<PaginationProps> => {
  const url = new URL(window.location.href)
  const perPage = url.searchParams.get('per_page')
  const page = url.searchParams.get('page')

  const onPerPageSelect: OnPerPageSelect = (_event, selectedPerPage) => {
    url.searchParams.set('per_page', String(selectedPerPage))
    url.searchParams.delete('page')
    window.location.replace(url.toString())
  }

  const goToPage = (page: any) => {
    url.searchParams.set('page', page)
    window.location.replace(url.toString())
  }

  return (
    <PFPagination
      itemCount={itemCount}
      page={Number(page)}
      perPage={Number(perPage) || 20}
      perPageOptions={[{ title: '10', value: 10 }, { title: '20', value: 20 }]}
      variant={variant}
      widgetId="pagination-options-menu-top"
      onFirstClick={(_ev, page) => goToPage(page)}
      onLastClick={(_ev, page) => goToPage(page)}
      onNextClick={(_ev, page) => goToPage(page)}
      onPerPageSelect={onPerPageSelect}
      onPreviousClick={(_ev, page) => goToPage(page)}
    />
  )
}

export { Pagination }
