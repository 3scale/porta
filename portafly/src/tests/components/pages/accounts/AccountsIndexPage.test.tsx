import React from 'react'

import { render } from 'tests/custom-render'
import { AccountsIndexPage } from 'components'
import { developerAccounts } from 'tests/examples'
import { useAsync, AsyncState } from 'react-async'
import { IDeveloperAccount } from 'types'
import { factories } from 'tests/factories'

jest.mock('react-async')

const setup = (asyncState: Partial<AsyncState<IDeveloperAccount[]>>) => {
  (useAsync as jest.Mock).mockReturnValueOnce(asyncState)
  return render(<AccountsIndexPage />)
}

it('should have a button to create an account', () => {
  const { getByRole } = setup({})
  const createAccountBtn = getByRole('link', { name: 'create_account_button_aria_label' })
  expect(createAccountBtn).toHaveTextContent('create_account_button')
  expect(createAccountBtn.getAttribute('href')).toBe('/accounts/new')
})

it('should be able to export all accounts', () => {
  const { getByText } = setup({ data: [factories.DeveloperAccount.build()] })
  const exportAccountsLink = getByText('export_accounts_button')
  expect(exportAccountsLink.getAttribute('href')).toContain('"ID","accounts_table.admin_header","accounts_table.group_header","accounts_table.state_header","accounts_table.applications_header","accounts_table.created_header","accounts_table.updated_header"\n"2","Oswell E. Spencer","Umbrella Corp.","approved","3","2019-10-18T05:13:26Z","2019-10-18T05:13:27Z"')
})

it('should disable the export all button when no data is provided', () => {
  const { getByRole } = setup({ data: undefined })
  const exportAccountsLink = getByRole('link', { name: 'export_accounts_button_aria_label' })
  expect(exportAccountsLink).toHaveClass('pf-m-disabled')
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
      expect(wrapper.getByText(account.adminName)).toBeInTheDocument()
    ))
  })
})
