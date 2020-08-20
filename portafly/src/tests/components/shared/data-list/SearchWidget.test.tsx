import React from 'react'

import { render } from 'tests/custom-render'
import { fireEvent } from '@testing-library/react'
import { SearchWidget } from 'components'
import { Toolbar, ToolbarContent, ToolbarItem } from '@patternfly/react-core'

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
    options: [
      {
        name: 'active',
        humanName: 'Active'
      },
      {
        name: 'pending',
        humanName: 'Pending'
      }
    ]
  }
]

describe('SearchWidget', () => {
  const setup = () => (
    render(
      <Toolbar id="data-toolbar">
        <ToolbarContent>
          <ToolbarItem data-testid="search-widget">
            <SearchWidget categories={categories} />
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>
    )
  )

  it('should render correctly', () => {
    const { getByTestId } = setup()
    expect(getByTestId('search-widget')).toMatchSnapshot()
  })

  it.skip('should be able to filter by admin', () => {
    // FIXME: Update test after MOB session
    const { getByPlaceholderText, getByTestId } = setup()
    const searchInput = getByPlaceholderText('accountsIndex:accounts_filter_field')
    fireEvent.change(searchInput, { target: { value: 'big boss' } })
    expect(getByTestId('data-toolbar')).toMatchSnapshot()
  })

  // TODO: PF React makes it hard to target the button of the select...
  it.skip('should be able to filter by state', () => {
  })
})
