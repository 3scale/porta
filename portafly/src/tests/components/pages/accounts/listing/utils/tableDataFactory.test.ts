import { generateColumns, generateRows } from 'components/pages/accounts/listing'
import { developerAccounts } from 'tests/examples'

it('should work', () => {
  const isMultitenant = false
  expect(generateColumns(jest.fn())).not.toBeUndefined()
  expect(generateRows(developerAccounts, isMultitenant)).not.toBeUndefined()
})
