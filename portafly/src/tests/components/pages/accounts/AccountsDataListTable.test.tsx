import React from 'react'
import { render } from 'tests/custom-render'
import { AccountsDataListTable } from 'components'
import { developerAccounts } from 'tests/examples'

it('should render', () => {
  const wrapper = render(<AccountsDataListTable accounts={developerAccounts} />)
  expect(wrapper).not.toBeUndefined()
})
