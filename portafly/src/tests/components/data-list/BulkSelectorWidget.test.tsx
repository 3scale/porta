import React from 'react'
import { BulkSelectorWidget } from 'components/data-list'
import { useDataListTable, useDataListPagination } from 'components/data-list/DataListContext'
import { fireEvent, within } from '@testing-library/react'
import { render } from 'tests/custom-render'

jest.mock('components/data-list/DataListContext')
const paginationMock = useDataListPagination as jest.Mock
paginationMock.mockReturnValue({ startIdx: 0, endIdx: 5 })
const useTableMock = useDataListTable as jest.Mock
useTableMock.mockReturnValue({ selectedRows: [] })

const filteredRows = new Array(5).map((_, i) => ({ id: i }))

const renderWidget = () => {
  const wrapper = render(<BulkSelectorWidget filteredRows={filteredRows} />)
  const dropdown = within(wrapper.container.querySelector('.pf-c-dropdown') as HTMLElement)
  return { ...wrapper, dropdown }
}

it('expands and collapses properly', () => {
  const { dropdown, queryByRole } = renderWidget()
  expect(queryByRole('menu')).not.toBeInTheDocument()

  const button = dropdown.getByRole('button')
  fireEvent.click(button)

  const withinMenu = within(queryByRole('menu') as HTMLElement)
  expect(withinMenu.getByText('bulk_selector.none')).toBeInTheDocument()
  expect(withinMenu.getByText('bulk_selector.page')).toBeInTheDocument()
  expect(withinMenu.getByText('bulk_selector.all')).toBeInTheDocument()

  fireEvent.click(button)
  expect(queryByRole('menu')).not.toBeInTheDocument()
})

describe('when no items are selected', () => {
  beforeEach(() => {
    useTableMock.mockReturnValueOnce({ selectedRows: [] })
  })

  it('input should be unchecked', () => {
    const { dropdown } = renderWidget()
    const checkbox = dropdown.queryByRole('checkbox') as HTMLInputElement
    expect(checkbox.indeterminate).toEqual(false)
    expect(checkbox.checked).toEqual(false)
  })
})

describe('when some items are selected', () => {
  beforeEach(() => {
    useTableMock.mockReturnValueOnce({ selectedRows: filteredRows.slice(0, 2) })
  })

  it('input should be indeterminate', () => {
    const { dropdown } = renderWidget()
    const checkbox = dropdown.queryByRole('checkbox') as HTMLInputElement
    expect(checkbox.indeterminate).toEqual(true)
    expect(checkbox.checked).toEqual(false)
  })
})

describe('when all items are selected', () => {
  beforeEach(() => {
    useTableMock.mockReturnValueOnce({ selectedRows: filteredRows })
  })

  it('input should be checked', () => {
    const { dropdown } = renderWidget()
    const checkbox = dropdown.queryByRole('checkbox') as HTMLInputElement
    expect(checkbox.indeterminate).toEqual(false)
    expect(checkbox.checked).toEqual(true)
  })
})
