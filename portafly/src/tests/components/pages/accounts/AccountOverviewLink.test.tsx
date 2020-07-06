import React from 'react'
import { render } from 'tests/custom-render'
import { factories } from 'tests/factories'
import { AccountOverviewLink } from 'components'

const account = factories.DeveloperAccount.build()

const setup = () => {
  const wrapper = render(<AccountOverviewLink account={account} />)
  const row = wrapper.getByText(account.orgName).closest('a') as HTMLElement
  return { ...wrapper, row }
}

it('should render properly', () => {
  const { row } = setup()
  expect(row).toBeInTheDocument()
})

it('should have a link', () => {
  const { row } = setup()
  expect(row.getAttribute('aria-label')).toBe('accounts_table.account_overview_link_aria_label')
})

it('should point to the correct url', () => {
  const { row } = setup()
  expect(row.getAttribute('href')).toMatch(`/accounts/${account.id}`)
})
