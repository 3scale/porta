import React from 'react'

import { render } from 'tests/custom-render'
import { AccountsListingPage } from 'components'
import { developerAccounts } from 'tests/examples'
import { useAsync, AsyncState } from 'react-async'
import { IDeveloperAccount } from 'types'

jest.mock('react-async')

const setup = (asyncState: Partial<AsyncState<IDeveloperAccount[]>>) => {
  (useAsync as jest.Mock).mockReturnValueOnce(asyncState)
  return render(<AccountsListingPage />)
}

it('should have a button to create an account', () => {
  const { getByRole } = setup({})
  const createAccountBtn = getByRole('button', { name: 'create_account_button_aria_label' })
  expect(createAccountBtn).toHaveTextContent('create_account_button')

  // TODO: assert href attribute
})

it('should be able to export all accounts', () => {
  const { getByRole } = setup({})
  const exportAccountsBtn = getByRole('button', { name: 'export_accounts_button_aria_label' })
  expect(exportAccountsBtn).toHaveTextContent('export_accounts_button')

  // TODO: test export?
})

describe('when the request is pending', () => {
  it('should render a loading spinner', () => {
    const wrapper = setup({ isPending: true })
    expect(wrapper.container.querySelector('.pf-c-spinner')).toBeInTheDocument()
    expect(wrapper.getByText(/loading/)).toBeInTheDocument()
  })
})

describe('when backend returns an error', () => {
  it('should render an alert', () => {
    const wrapper = setup({ error: { name: 'SomeError', message: 'ERROR' } })
    expect(wrapper.container.querySelector('.pf-c-alert.pf-m-danger')).toBeInTheDocument()
    expect(wrapper.getByText('ERROR')).toBeInTheDocument()
  })
})

describe('when backend returns a list of accounts', () => {
  it('should render a table with accounts', () => {
    const wrapper = setup({ data: developerAccounts })
    developerAccounts.forEach((account: IDeveloperAccount) => (
      expect(wrapper.getByText(account.admin_name)).toBeInTheDocument()
    ))
  })
})
