import React from 'react'

import { generateColumns, generateRows } from 'components/pages/accounts/utils'
import { ActionButtonImpersonate } from 'components/pages/accounts'
import { developerAccounts } from 'tests/examples'

it('should generate columns', () => {
  const columns = generateColumns(jest.fn())
  expect(columns).toMatchSnapshot()
})

describe.skip('when it is provider', () => {
  beforeAll(() => {
    process.env.REACT_APP_MULTITENANT = null
  })
})

describe('when it is multitenant', () => {
  beforeAll(() => {
    process.env.REACT_APP_MULTITENANT = 'true'
  })

  // TODO: this feature has been removed temporarily
  it.skip('should render an impersonate button as action', () => {
    expect(generateRows(developerAccounts.slice(0, 1)))
      .toMatchObject([{
        cells: expect.arrayContaining([{
          stringValue: expect.any(String),
          title: <ActionButtonImpersonate />
        }])
      }])
  })
})
