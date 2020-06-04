import React from 'react'

import { render } from 'tests/custom-render'
import { fireEvent } from '@testing-library/react'
import { PaginationWidget, useDataListPagination } from 'components'

jest.mock('components/shared/data-list/DataListContext')
const useDataListPaginationMock = useDataListPagination as jest.Mock

it('should render compacted when there are 1-2 pages only', () => {
  useDataListPaginationMock.mockReturnValue({ perPage: 1 })

  const wrapper = render(<PaginationWidget itemCount={1} />)
  expect(wrapper.container.querySelector('.pf-m-compact')).toBeInTheDocument()

  wrapper.rerender(<PaginationWidget itemCount={2} />)
  expect(wrapper.container.querySelector('.pf-m-compact')).toBeInTheDocument()

  wrapper.rerender(<PaginationWidget itemCount={3} />)
  expect(wrapper.container.querySelector('.pf-m-compact')).not.toBeInTheDocument()
})

it('should change list section when paginating', () => {
  const setPagination = jest.fn()
  useDataListPaginationMock.mockReturnValue({
    page: 1,
    perPage: 5,
    startIdx: 0,
    endIdx: 5,
    setPagination
  })

  const { container } = render(<PaginationWidget itemCount={10} />)
  fireEvent.click(container.querySelector('button[data-action="next"]') as Element)

  expect(setPagination)
    .toHaveBeenCalledWith(expect.objectContaining({ page: 2, startIdx: 5, endIdx: 10 }))
})
