import { generateColumns, generateRows } from 'components/pages/accounts'
import { developerAccounts } from 'tests/examples'

it('should work', () => {
  process.env.REACT_APP_MULTITENANT = 'false'
  expect(generateColumns(jest.fn())).not.toBeUndefined()
  expect(generateRows(developerAccounts)).not.toBeUndefined()
})
