import React, { useState } from 'react'
import { fireEvent } from '@testing-library/react'
import { render } from 'tests/custom-render'
import { DataListProvider, useDataListFilters, useDataListData } from 'components'
import { factories } from 'tests/factories'
import { IDeveloperAccount } from 'types'

describe('DataListContext: useDataFilters', () => {
  const FilterComponent = () => {
    const { filters, setFilters } = useDataListFilters()
    const [bandName, setBandName] = useState('')
    const onChange = (ev: React.ChangeEvent<HTMLInputElement>) => (
      setBandName(ev.currentTarget.value)
    )
    const addBandsFilters = () => {
      const oldFilters = filters.bands || []
      setFilters({ bands: oldFilters.concat(bandName) })
    }
    return (
      <>
        <p>
          Filter by Band:
          <span data-testid="filters">{ filters.bands ? filters.bands.map((name) => `${name} `) : '' }</span>
        </p>
        <input data-testid="name" onChange={onChange} value={bandName} />
        {/* eslint-disable-next-line react/button-has-type */}
        <button data-testid="add" onClick={addBandsFilters}>Add</button>
        {/* eslint-disable-next-line react/button-has-type */}
        <button data-testid="clear" onClick={() => setFilters({})}>Clear</button>
      </>
    )
  }

  const DataList = () => (
    <DataListProvider initialState={{ table: { columns: [], rows: [] } }}>
      <FilterComponent />
    </DataListProvider>
  )

  it('should correctly update the state using reducer hook functions', () => {
    const { getByTestId } = render(<DataList />)

    const filters = getByTestId('filters')
    const input = getByTestId('name')
    const addButton = getByTestId('add')
    const clearButton = getByTestId('clear')

    fireEvent.change(input, { target: { value: 'Radiohead' } })
    fireEvent.click(addButton)
    fireEvent.change(input, { target: { value: 'Blur' } })
    fireEvent.click(addButton)

    expect(filters.innerHTML).toBe('Radiohead Blur ')

    fireEvent.click(clearButton)
    expect(filters.innerHTML).toBe('')
  })
})

describe('DataListContext: useDataListData', () => {
  const ExampleComponent = () => {
    const { data, setData } = useDataListData()
    const [adminName, setAdminName] = useState('')
    const onChange = (ev: React.ChangeEvent<HTMLInputElement>) => (
      setAdminName(ev.currentTarget.value)
    )

    const addAccount = () => (
      setData(
        [...data, ...[factories.DeveloperAccount.build({ adminName })]]
      )
    )

    return (
      <>
        <ul data-testid="accounts">
          { (data as IDeveloperAccount[]).map((account) => (
            <li key={account.adminName}>{account.adminName}</li>
          )) }
        </ul>
        <input data-testid="adminName" onChange={onChange} value={adminName} />
        {/* eslint-disable-next-line react/button-has-type */}
        <button data-testid="add" onClick={addAccount}>Add</button>
      </>
    )
  }

  const DataList = () => (
    <DataListProvider initialState={{ data: [factories.DeveloperAccount.build({ adminName: 'John' })] }}>
      <ExampleComponent />
    </DataListProvider>
  )

  it('should consume data stored in the context', () => {
    const { getByTestId, getByText } = render(<DataList />)

    const input = getByTestId('adminName')
    const addButton = getByTestId('add')

    const firstRenderAdminNames = ['John']
    firstRenderAdminNames.forEach((name) => expect(getByText(name)).toBeInTheDocument())

    fireEvent.change(input, { target: { value: 'Ringo' } })
    fireEvent.click(addButton)
    fireEvent.change(input, { target: { value: 'George' } })
    fireEvent.click(addButton)

    const addedAdminNames = ['John', 'Ringo', 'George']
    addedAdminNames.forEach((name) => expect(getByText(name)).toBeInTheDocument())
  })
})
