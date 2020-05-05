import { DataListProvider, useDataListFilters } from 'components/data-list'

import React, { useState } from 'react'
import { render, fireEvent } from '@testing-library/react'

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
