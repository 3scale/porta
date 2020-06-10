import React from 'react'

import {
  generateColumns,
  generateRows,
  ActionButtonImpersonate,
  ActionButtonActivate,
  ActionButtonApprove
} from 'components/pages/accounts'
import { developerAccounts } from 'tests/examples'

it('should generate columns', () => {
  const columns = generateColumns(jest.fn())
  expect(columns).toMatchSnapshot()
})

describe('when it is provider', () => {
  beforeAll(() => {
    process.env.REACT_APP_MULTITENANT = 'false'
  })

  it('should render an activate button when account is suspended', () => {
    const suspendedAccount = { ...developerAccounts[0], state: 'suspended' }
    expect(generateRows([suspendedAccount]))
      .toMatchObject([{ cells: expect.arrayContaining([{ title: <ActionButtonActivate /> }]) }])
  })

  it('should render an approve button when account is pending', () => {
    const pendingAccount = { ...developerAccounts[0], state: 'pending' }
    expect(generateRows([pendingAccount]))
      .toMatchObject([{ cells: expect.arrayContaining([{ title: <ActionButtonApprove /> }]) }])
  })
})

describe('when it is multitenant', () => {
  beforeAll(() => {
    process.env.REACT_APP_MULTITENANT = 'true'
  })

  it('should render an impersonate button as action', () => {
    expect(generateRows(developerAccounts.slice(0, 1)))
      .toMatchObject([{ cells: expect.arrayContaining([{ title: <ActionButtonImpersonate /> }]) }])
  })
})
