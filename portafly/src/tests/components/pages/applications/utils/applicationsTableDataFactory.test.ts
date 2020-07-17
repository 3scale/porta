import { generateColumns, generateRows } from 'components/pages/applications/utils'
import { factories } from 'tests/factories'

it('should generate columns', () => {
  const columns = generateColumns(jest.fn())
  expect(columns).toMatchSnapshot()
})

it('should generate rows', () => {
  const applications = factories.Application.buildList(1)
  const columns = generateRows(applications)
  expect(columns).toMatchSnapshot()
})
