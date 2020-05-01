import React from 'react'
import { render } from 'tests/custom-render'
import { SearchWidget } from 'components/data-list'
import { fireEvent } from '@testing-library/react'
import { DataToolbar, DataToolbarContent, DataToolbarItem } from '@patternfly/react-core/dist/js/experimental'

describe('SearchWidget', () => {
  const categories = [
    {
      name: 'admin',
      humanName: 'Admin'
    },
    {
      name: 'group',
      humanName: 'Organization / Group'
    },
    {
      name: 'state',
      humanName: 'State',
      options: {
        active: 'Active',
        pending: 'Pending'
      }
    }
  ]

  const setup = () => (
    render(
      <DataToolbar id="data-list" data-testid="data-toolbar" className="DataToolbar-class" clearAllFilters={jest.fn()}>
        <DataToolbarContent>
          <DataToolbarItem>
            <SearchWidget categories={categories} />
          </DataToolbarItem>
        </DataToolbarContent>
      </DataToolbar>
    )
  )

  it('should render correctly', () => {
    const { getByTestId } = setup()
    expect(getByTestId('data-toolbar')).toMatchSnapshot()
  })

  it('should be able to filter by admin', () => {
    const { getByPlaceholderText, getByTestId } = setup()
    const searchInput = getByPlaceholderText('Filter by Admin')
    fireEvent.change(searchInput, { target: { value: 'big boss' } })
    expect(getByTestId('data-toolbar')).toMatchSnapshot()
  })

  it.skip('should be able to filter by state', () => {
    // FIXME: PF React makes it hard to target the button of the select...
  })
})
