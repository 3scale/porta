import React from 'react'
import { render } from 'tests/custom-render'
import {
  AccountsTable,
  useDataListTable,
  useDataListPagination,
  useDataListFilters
} from 'components'
import { generateColumns, generateRows } from 'components/pages/accounts/utils'
import { within } from '@testing-library/react'
import { IDeveloperAccount } from 'types'
import { factories } from 'tests/factories'

jest.mock('components/shared/data-list/DataListContext')
const useTableMock = useDataListTable as jest.Mock
const usePaginationMock = useDataListPagination as jest.Mock
const useFiltersMock = useDataListFilters as jest.Mock
const developerAccounts: IDeveloperAccount[] = [['Dandelion', 'Rosemary and Thyme'], ['Geralt', 'Wolf School']].map((account) => (
  factories.DeveloperAccount.build({
    adminName: account[0],
    orgName: account[1]
  })
))

const rows = generateRows(developerAccounts)
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
  const wrapper = render(<AccountsTable />)
  const table = within(wrapper.queryByRole('grid') as HTMLElement)
  const getRow = (account: IDeveloperAccount) => table.getByText(account.orgName).closest('tr') as HTMLElement

  return {
    ...wrapper,
    getRow
  }
}
it('should render the data list table with the accounts provided', () => {
  const { queryByText, getRow } = setup()
  developerAccounts.map((account) => expect(getRow(account)).toBeInTheDocument())
  expect(queryByText(/accounts_table.empty_state/)).not.toBeInTheDocument()
})

it('should render an empty view when there are NO accounts', () => {
  useTableMock.mockReturnValue({ ...defaultTable, rows: [] })
  const { getByText } = setup()
  expect(getByText(/accounts_table.empty_state/)).toBeInTheDocument()
})
