import { Button } from '@patternfly/react-core'
import { AngleLeftIcon, AngleRightIcon } from '@patternfly/react-icons'

import type { FunctionComponent } from 'react'

import './MicroPagination.scss'

interface Props {
  page: number;
  lastPage: number;
  setPage: (page: number) => void;
}

const MicroPagination: FunctionComponent<Props> = ({
  page,
  lastPage,
  setPage
}) => {
  const onPrevious = () => { setPage(page - 1) }
  const onNext = () => { setPage(page + 1) }

  return (
    <div className="pf-c-pagination pf-c-pagination__micro">
      <nav aria-label="Pagination" className="pf-c-pagination__nav">
        <Button aria-label="Go to previous page" isDisabled={page === 1} variant="plain" onClick={onPrevious}>
          <AngleLeftIcon />
        </Button>
        <Button aria-label="Go to next page" isDisabled={page === lastPage} variant="plain" onClick={onNext}>
          <AngleRightIcon />
        </Button>
      </nav>
    </div>
  )
}

export { MicroPagination, Props }
