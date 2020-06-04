import React from 'react'

import { fireEvent, within } from '@testing-library/react'
import { render } from 'tests/custom-render'
import {
  BulkSelectorWidget,
  filterRows,
  useDataListTable,
  useDataListPagination,
  useDataListFilters
} from 'components'

const rows = new Array(5).fill({}).map((_, i) => ({ id: i }))

jest.mock('components/shared/data-list/DataListContext')
jest.mock('components/shared/data-list/utils/filterRows')

const setup = ({ selectedRows }: any) => {
  (useDataListPagination as jest.Mock).mockReturnValue({ startIdx: 0, endIdx: 5 });
  (useDataListTable as jest.Mock).mockReturnValue({ rows, selectedRows });
  (useDataListFilters as jest.Mock).mockReturnValue({});
  (filterRows as jest.Mock).mockReturnValue(rows)

  const wrapper = render(<BulkSelectorWidget />)
  const dropdown = within(wrapper.container.querySelector('.pf-c-dropdown') as HTMLElement)
  return { ...wrapper, dropdown }
}

it('expands and collapses properly', () => {
  const { dropdown, queryByRole } = setup({ selectedRows: [] })
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
  const { dropdown } = setup({ selectedRows: [] })
  it('input should be unchecked', () => {
    const checkbox = dropdown.queryByRole('checkbox') as HTMLInputElement
    expect(checkbox.indeterminate).toEqual(false)
    expect(checkbox.checked).toEqual(false)
  })
})

describe('when some items are selected', () => {
  const { dropdown } = setup({ selectedRows: rows.slice(0, 2) })
  it('input should be indeterminate', () => {
    const checkbox = dropdown.queryByRole('checkbox') as HTMLInputElement
    expect(checkbox.indeterminate).toEqual(true)
    expect(checkbox.checked).toEqual(false)
  })
})

describe('when all items are selected', () => {
  const { dropdown } = setup({ selectedRows: rows })
  it('input should be checked', () => {
    const checkbox = dropdown.queryByRole('checkbox') as HTMLInputElement
    expect(checkbox.indeterminate).toEqual(false)
    expect(checkbox.checked).toEqual(true)
  })
})
