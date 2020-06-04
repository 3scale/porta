import React from 'react'

import { render } from 'tests/custom-render'
import { DeveloperAccounts } from 'components'
import { developerAccounts } from 'tests/examples'
import { useAsync } from 'react-async'

jest.mock('react-async')

describe('when the request is pending', () => {
  (useAsync as jest.Mock).mockReturnValueOnce({ isPending: true })

  it('should render spinner', () => {
    const wrapper = render(<DeveloperAccounts />)
    expect(wrapper).toMatchSnapshot()
  })
})

describe('when backend returns an error', () => {
  (useAsync as jest.Mock).mockReturnValueOnce({ error: { message: 'ERROR' } })

  it('should render an alert', () => {
    const wrapper = render(<DeveloperAccounts />)
    expect(wrapper).toMatchSnapshot()
  })
})

describe('when backend returns a list of accounts', () => {
  (useAsync as jest.Mock).mockReturnValueOnce({ data: developerAccounts })

  it('should render a table with accounts', () => {
    const wrapper = render(<DeveloperAccounts />)
    expect(wrapper).toMatchSnapshot()
  })
})
