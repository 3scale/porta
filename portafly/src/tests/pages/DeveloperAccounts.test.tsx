import React from 'react'

import { render } from 'tests/custom-render'
import { DeveloperAccounts } from 'pages'
import { useGetDeveloperAccounts } from 'dal/accounts'
import { developerAccounts } from 'tests/examples'

jest.mock('dal/accounts')

describe('when the request is pending', () => {
  (useGetDeveloperAccounts as jest.Mock).mockReturnValueOnce({ isPending: true })

  it('should render spinner', () => {
    const wrapper = render(<DeveloperAccounts />)
    expect(wrapper).toMatchSnapshot()
  })
})

describe('when backend returns an error', () => {
  (useGetDeveloperAccounts as jest.Mock).mockReturnValueOnce({ error: { message: 'ERROR' } })

  it('should render an alert', () => {
    const wrapper = render(<DeveloperAccounts />)
    expect(wrapper).toMatchSnapshot()
  })
})

describe('when backend returns a list of accounts', () => {
  (useGetDeveloperAccounts as jest.Mock).mockReturnValueOnce({ accounts: developerAccounts })

  it('should render a table with accounts', () => {
    const wrapper = render(<DeveloperAccounts />)
    expect(wrapper).toMatchSnapshot()
  })
})
