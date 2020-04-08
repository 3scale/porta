import React from 'react'

import { render } from 'tests/custom-render'
import { DeveloperAccountsTable } from 'components'
import { developerAccounts } from 'tests/examples'

describe('when there are any accounts', () => {
  it('should render a table with accounts', () => {
    const wrapper = render(<DeveloperAccountsTable accounts={developerAccounts} />)
    expect(wrapper).toMatchSnapshot()
  })
})

describe('when there are NO accounts', () => {
  it('should render an empty view', () => {
    const wrapper = render(<DeveloperAccountsTable accounts={[]} />)
    expect(wrapper).toMatchSnapshot()
  })
})
