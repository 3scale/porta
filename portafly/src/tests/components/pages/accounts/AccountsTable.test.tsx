import React from 'react'

import { render } from 'tests/custom-render'
import {
  useDataListTable,
  useDataListPagination,
  useDataListFilters,
  useDataListBulkActions
} from 'components'
import { AccountsTable, generateColumns, generateRows } from 'components/pages/accounts'
import { developerAccounts } from 'tests/examples'
import { fireEvent, within } from '@testing-library/react'
import { IDeveloperAccount } from 'types'

jest.mock('components/shared/data-list/DataListContext')
const useTableMock = useDataListTable as jest.Mock
const usePaginationMock = useDataListPagination as jest.Mock
const useFiltersMock = useDataListFilters as jest.Mock
const useBulkActionsMock = useDataListBulkActions as jest.Mock

const rows = generateRows(developerAccounts, false)
const columns = generateColumns((s: string) => s)

const isChecked = (c: HTMLElement) => (c as HTMLInputElement).checked

const defaultTable = {
  rows,
  columns,
  selectedRows: [],
  sortBy: {},
  setSortBy: jest.fn(),
  selectOne: jest.fn(),
  selectPage: jest.fn(),
  selectAll: jest.fn()
}
const resetPagination = jest.fn()
const defaultPagination = { startIdx: 0, endIdx: 5, resetPagination }
const defaultFilters = { filters: {} }
const defaultBulkActions = {}
const resetMocks = () => {
  useTableMock.mockReturnValue(defaultTable)
  usePaginationMock.mockReturnValue(defaultPagination)
  useFiltersMock.mockReturnValue(defaultFilters)
  useBulkActionsMock.mockReturnValue(defaultBulkActions)
}
beforeAll(resetMocks)
afterEach(resetMocks)

const setup = () => {
  const wrapper = render(<AccountsTable />)
  const getRow = (account: IDeveloperAccount) => wrapper.getByText(account.org_name).closest('tr') as HTMLElement
  const bulkSelectorDropdown = within(wrapper.container.querySelector('#data-list-bulk-selector-dropdown') as HTMLElement)
  const bulkActionsDropdown = within(wrapper.container.querySelector('#data-list-bulk-actions-dropdown') as HTMLElement)

  return {
    ...wrapper,
    getRow,
    bulkSelectorDropdown,
    bulkActionsDropdown
  }
}

it('should be able to sort columns', () => {
  const { container } = setup()
  const table = within(container.querySelector('table') as HTMLElement)
  fireEvent.click(table.getByText(/accounts_table.group_header/))

  expect(defaultTable.setSortBy).toHaveBeenLastCalledWith(1, 'asc', true)
})

describe('when there are any accounts, but none selected', () => {
  beforeEach(() => {
    useTableMock.mockReturnValue({ ...defaultTable, selectedRows: [] })
  })

  it('should be able to select one account', () => {
    const wrapper = setup()
    const checkboxes = wrapper.getAllByRole('checkbox')
    expect(checkboxes).toHaveLength(developerAccounts.length + 1)
    expect(checkboxes.some(isChecked)).toBe(false)
    // TODO: assert text '0 Selected' in BulkSelectorWidget test

    const account = developerAccounts[0]
    const row = wrapper.getRow(account)
    fireEvent.click(within(row).getByRole('checkbox'))

    expect(defaultTable.selectOne).toHaveBeenLastCalledWith(account.id, true)
  })

  it('should be able to select all accounts in a page', () => {
    const { bulkSelectorDropdown: dropdown } = setup()

    fireEvent.click(dropdown.getByRole('button'))
    fireEvent.click(dropdown.getByText('bulk_selector.page'))

    expect(defaultTable.selectPage).toHaveBeenLastCalledWith(expect.any(Array))
  })

  it('should be able to select all accounts', () => {
    const { bulkSelectorDropdown: dropdown } = setup()

    fireEvent.click(dropdown.getByRole('button'))
    fireEvent.click(dropdown.getByText('bulk_selector.all'))

    expect(defaultTable.selectAll).toHaveBeenNthCalledWith(1, true, expect.any(Array))
  })

  it('should select all when clicking the checkbox', () => {
    const { bulkSelectorDropdown: dropdown } = setup()

    fireEvent.click(dropdown.getByRole('checkbox'))

    expect(defaultTable.selectAll).toHaveBeenLastCalledWith(true, expect.any(Array))
  })

  it('should display bulk actions disabled and a warning', () => {
    const { bulkActionsDropdown: dropdown } = setup()

    fireEvent.click(dropdown.getByRole('button'))

    expect(dropdown.getByText('bulk_actions.warning')).toBeInTheDocument()
    expect(dropdown.getByText('shared:bulk_actions.send_email')).toBeDisabled()
    expect(dropdown.getByText('shared:bulk_actions.change_state')).toBeDisabled()
  })
})

describe('when there are any accounts, and some are selected', () => {
  const selectedAccount = developerAccounts[0]

  beforeEach(() => {
    useTableMock.mockReturnValue({
      ...defaultTable,
      rows: rows.map((r) => ({ ...r, selected: r.id === selectedAccount.id })),
      selectedRows: rows.slice(0, 1)
    })
  })

  it('should render selected accounts and be able to deselect them', () => {
    const wrapper = setup()
    const checkboxes = wrapper.getAllByRole('checkbox')
    expect(checkboxes).toHaveLength(developerAccounts.length + 1)
    expect(checkboxes.filter(isChecked)).toHaveLength(1)
    // TODO: assert text '1 Selected' in BulkSelectorWidget test

    const row = wrapper.getRow(selectedAccount)
    fireEvent.click(within(row).getByRole('checkbox'))

    expect(defaultTable.selectOne).toHaveBeenLastCalledWith(selectedAccount.id, false)
  })

  it('should remove all selections when clicking the checkbox', () => {
    const { bulkSelectorDropdown: dropdown } = setup()

    fireEvent.click(dropdown.getByRole('checkbox'))

    expect(defaultTable.selectAll).toHaveBeenLastCalledWith(false, expect.any(Array))
  })

  it('should be able to deselect all', () => {
    const { bulkSelectorDropdown: dropdown } = setup()

    fireEvent.click(dropdown.getByRole('button'))
    fireEvent.click(dropdown.getByText('bulk_selector.none'))

    expect(defaultTable.selectAll).toHaveBeenLastCalledWith(false)
  })

  it('should display bulk actions enabled and no warning', () => {
    const { bulkActionsDropdown: dropdown } = setup()

    fireEvent.click(dropdown.getByRole('button'))

    expect(dropdown.queryByText('bulk_actions.warning')).not.toBeInTheDocument()
    expect(dropdown.getByText('shared:bulk_actions.send_email')).toBeEnabled()
    expect(dropdown.getByText('shared:bulk_actions.send_email')).toBeEnabled()
  })
})

describe('when there are any accounts, and all are selected', () => {
  beforeEach(() => {
    useTableMock.mockReturnValue({
      ...defaultTable,
      rows: rows.map((r) => ({ ...r, selected: true })),
      selectedRows: rows
    })
  })

  it('should render selected accounts and be able to deselect them', () => {
    const wrapper = setup()
    const checkboxes = wrapper.getAllByRole('checkbox')
    expect(checkboxes).toHaveLength(developerAccounts.length + 1)
    expect(checkboxes.every(isChecked)).toBe(true)
    // TODO: assert text '2 Selected' in BulkSelectorWidget test

    const account = developerAccounts[0]
    const row = wrapper.getRow(account)
    fireEvent.click(within(row).getByRole('checkbox'))

    expect(defaultTable.selectOne).toHaveBeenLastCalledWith(account.id, false)
  })

  it('should remove all selections when clicking the checkbox', () => {
    const { bulkSelectorDropdown: dropdown } = setup()

    fireEvent.click(dropdown.getByRole('checkbox'))

    expect(defaultTable.selectAll).toHaveBeenLastCalledWith(false, expect.any(Array))
  })

  it('should be able to deselect all', () => {
    const { bulkSelectorDropdown: dropdown } = setup()

    fireEvent.click(dropdown.getByRole('button'))
    fireEvent.click(dropdown.getByText('bulk_selector.none'))

    expect(defaultTable.selectAll).toHaveBeenLastCalledWith(false)
  })
})

describe('when there are any filters', () => {
  const filteredAccount = developerAccounts[0]
  const hiddenAccount = developerAccounts[1]

  beforeEach(() => {
    useFiltersMock.mockReturnValue({
      filters: {
        admin: [filteredAccount.admin_name]
      }
    })
  })

  it('should render only filtered rows', () => {
    const { getRow } = setup()

    expect(getRow(filteredAccount)).toBeInTheDocument()
    expect(() => getRow(hiddenAccount)).toThrowError()
  })
})

describe('when there are NO accounts', () => {
  beforeEach(() => {
    useTableMock.mockReturnValue({ ...defaultTable, rows: [] })
  })

  it('should render an empty view', () => {
    const { getByText } = setup()
    expect(getByText(/accounts_table.empty_state/)).toBeInTheDocument()
  })
})
