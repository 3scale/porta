import React from 'react'

import { render } from 'tests/custom-render'
import {
  ApplicationsTable,
  useDataListTable,
  useDataListPagination,
  useDataListFilters
} from 'components'
import { generateColumns, generateRows } from 'components/pages/applications/utils'
import { fireEvent, within } from '@testing-library/react'
import { IApplication } from 'types'
import { factories } from 'tests/factories'

jest.mock('components/shared/data-list/DataListContext')
const useTableMock = useDataListTable as jest.Mock
const usePaginationMock = useDataListPagination as jest.Mock
const useFiltersMock = useDataListFilters as jest.Mock

const applications = factories.Application.buildList(2)
const rows = generateRows(applications)
const columns = generateColumns((s: string) => s)

const defaultTable = {
  rows,
  columns,
  sortBy: {},
  setSortBy: jest.fn()
}
const resetPagination = jest.fn()
const defaultPagination = { startIdx: 0, endIdx: 5, resetPagination }
const defaultFilters = { filters: {} }
const resetMocks = () => {
  useTableMock.mockReturnValue(defaultTable)
  usePaginationMock.mockReturnValue(defaultPagination)
  useFiltersMock.mockReturnValue(defaultFilters)
}
beforeAll(resetMocks)
afterEach(resetMocks)

const setup = () => {
  const wrapper = render(<ApplicationsTable applications={applications} />)
  const table = within(wrapper.queryByRole('grid', { name: 'applications_table.aria_label' }) as HTMLElement)
  const getRow = (application: IApplication) => table.getByText(application.name).closest('tr') as HTMLElement

  return { ...wrapper, getRow }
}

it('should be able to sort columns', () => {
  const { container } = setup()
  const table = within(container.querySelector('table') as HTMLElement)

  defaultTable.setSortBy.mockReset()
  fireEvent.click(table.getByText(/applications_table.name_header/))
  expect(defaultTable.setSortBy).toHaveBeenCalled()
})

describe('when there are any filters', () => {
  const filteredApplication = applications[0]
  const hiddenApplication = applications[1]

  beforeEach(() => {
    useFiltersMock.mockReturnValue({
      filters: {
        name: [filteredApplication.name]
      }
    })
  })

  it('should render only filtered rows', () => {
    const { getRow } = setup()
    expect(getRow(filteredApplication)).toBeInTheDocument()
    expect(() => getRow(hiddenApplication)).toThrowError()
  })
})

describe('when there are NO applications', () => {
  beforeEach(() => {
    useTableMock.mockReturnValue({ ...defaultTable, rows: [] })
  })

  it('should render an empty view', () => {
    const { getByText } = setup()
    expect(getByText(/applications_table.empty_state/)).toBeInTheDocument()
  })
})
