import React from 'react'
import { render } from 'tests/custom-render'
import {
  useDataListTable,
  useDataListPagination,
  useDataListFilters,
  useDataListBulkActions
} from 'components'
import { DataListTable } from 'tests/components/shared/data-list/examples/DataListTable'
import { fireEvent, within } from '@testing-library/react'
import { sortable } from '@patternfly/react-table'

jest.mock('components/shared/data-list/DataListContext')
const useTableMock = useDataListTable as jest.Mock
const usePaginationMock = useDataListPagination as jest.Mock
const useFiltersMock = useDataListFilters as jest.Mock
const useBulkActionsMock = useDataListBulkActions as jest.Mock

const columns = [
  {
    categoryName: 'name',
    title: 'Name',
    transforms: [sortable]
  },
  {
    categoryName: 'species',
    title: 'Species / Race',
    transforms: [sortable]
  },
  {
    categoryName: 'nationality',
    title: 'Nationality',
    transforms: [sortable]
  },
  {
    categoryName: 'state',
    title: 'State',
    transforms: [sortable]
  }
]

const characters = [
  {
    id: 1,
    name: 'Calanthe',
    species: 'Human',
    nationality: 'Cintra',
    state: 'Deceased'
  },
  {
    id: 2,
    name: 'Geralt',
    species: 'Witcher',
    nationality: '',
    state: 'Alive'
  },
  {
    id: 3,
    name: 'Cirilla',
    species: 'Human',
    nationality: 'Cintra',
    state: 'Alive'
  },
  {
    id: 4,
    name: 'Zoltan',
    species: 'Dwarf',
    nationality: 'Mahakam',
    state: 'Alive'
  }
]

const rows = characters.map((c) => ({
  id: c.id,
  cells: Object.keys(c).filter((k) => k !== 'id').map((k) => c[k]),
  selected: false
}))

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
  const wrapper = render(<DataListTable />)
  const table = within(wrapper.queryByRole('grid') as HTMLElement)
  const getRow = (character) => table.getByText(character.name).closest('tr') as HTMLElement
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

  expect(defaultTable.setSortBy).not.toHaveBeenCalled()

  fireEvent.click(table.getByText(/Name/))
  expect(defaultTable.setSortBy).toHaveBeenCalled()
})

describe('when there are any records, but none selected', () => {
  beforeEach(() => {
    useTableMock.mockReturnValue({ ...defaultTable, selectedRows: [] })
  })

  it('should be able to select one record', () => {
    const wrapper = setup()
    const checkboxes = wrapper.getAllByRole('checkbox')
    expect(checkboxes).toHaveLength(characters.length + 1)
    expect(checkboxes.some(isChecked)).toBe(false)
    // TODO: assert text '0 Selected' in BulkSelectorWidget test

    const character = characters[0]
    const row = wrapper.getRow(character)
    fireEvent.click(within(row).getByRole('checkbox'))

    expect(defaultTable.selectOne).toHaveBeenLastCalledWith(character.id, true)
  })

  it('should be able to select all records in a page', () => {
    const { bulkSelectorDropdown: dropdown } = setup()

    fireEvent.click(dropdown.getByRole('button'))
    fireEvent.click(dropdown.getByText('bulk_selector.page'))

    expect(defaultTable.selectPage).toHaveBeenLastCalledWith(expect.any(Array))
  })

  it('should be able to select all records', () => {
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
    expect(dropdown.getByText('Send Raven')).toBeDisabled()
    expect(dropdown.getByText('Change State')).toBeDisabled()
  })
})

describe('when there are any records, and some are selected', () => {
  const selectedCharacter = characters[0]

  beforeEach(() => {
    useTableMock.mockReturnValue({
      ...defaultTable,
      rows: rows.map((r) => ({ ...r, selected: r.id === selectedCharacter.id })),
      selectedRows: rows.slice(0, 1)
    })
  })

  it('should render selected records and be able to deselect them', () => {
    const wrapper = setup()
    const checkboxes = wrapper.getAllByRole('checkbox')
    expect(checkboxes).toHaveLength(characters.length + 1)
    expect(checkboxes.filter(isChecked)).toHaveLength(1)
    // TODO: assert text '1 Selected' in BulkSelectorWidget test

    const row = wrapper.getRow(selectedCharacter)
    fireEvent.click(within(row).getByRole('checkbox'))

    expect(defaultTable.selectOne).toHaveBeenLastCalledWith(selectedCharacter.id, false)
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
    expect(dropdown.getByText('Send Raven')).toBeEnabled()
    expect(dropdown.getByText('Change State')).toBeEnabled()
  })
})

describe('when there are any records, and all are selected', () => {
  beforeEach(() => {
    useTableMock.mockReturnValue({
      ...defaultTable,
      rows: rows.map((r) => ({ ...r, selected: true })),
      selectedRows: rows
    })
  })

  it('should render selected records and be able to deselect them', () => {
    const wrapper = setup()
    const checkboxes = wrapper.getAllByRole('checkbox')
    expect(checkboxes).toHaveLength(characters.length + 1)
    expect(checkboxes.every(isChecked)).toBe(true)
    // TODO: assert text '2 Selected' in BulkSelectorWidget test

    const character = characters[0]
    const row = wrapper.getRow(character)
    fireEvent.click(within(row).getByRole('checkbox'))

    expect(defaultTable.selectOne).toHaveBeenLastCalledWith(character.id, false)
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
  const filteredCharacter = characters[0]
  const hiddenCharacter = characters[1]

  beforeEach(() => {
    useFiltersMock.mockReturnValue({
      filters: {
        state: ['deceased']
      }
    })
  })

  it('should render only filtered rows', () => {
    const { getRow } = setup()

    expect(getRow(filteredCharacter)).toBeInTheDocument()
    expect(() => getRow(hiddenCharacter)).toThrowError()
  })
})

describe('when there are NO accounts', () => {
  beforeEach(() => {
    useTableMock.mockReturnValue({ ...defaultTable, rows: [] })
  })

  it('should render an empty view', () => {
    const { getByText } = setup()
    expect(getByText('No characters found')).toBeInTheDocument()
  })
})
