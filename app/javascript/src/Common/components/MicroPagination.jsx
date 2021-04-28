// @flow

import * as React from 'react'

import { Button } from '@patternfly/react-core'
import { AngleLeftIcon, AngleRightIcon } from '@patternfly/react-icons'

type Props = {
  page: number,
  lastPage: number,
  setPage: (page: number) => void
}

const MicroPagination = ({ page, lastPage, setPage }: Props): React.Node => {
  const onPrevious = () => setPage(page - 1)
  const onNext = () => setPage(page + 1)

  return (
    <div className="pf-c-pagination pf-c-pagination__micro">
      <nav className="pf-c-pagination__nav" aria-label="Pagination">
        <Button variant="plain" aria-label="Go to previous page" onClick={onPrevious} isDisabled={page === 1}>
          <AngleLeftIcon />
        </Button>
        <Button variant="plain" aria-label="Go to next page" onClick={onNext} isDisabled={page === lastPage}>
          <AngleRightIcon />
        </Button>
      </nav>
    </div>
  )
}

export { MicroPagination }
