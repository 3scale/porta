import { mount } from 'enzyme'

import { TableToolbar } from 'Common/components/TableToolbar'

import type { Props } from 'Common/components/TableToolbar'

const defaultProps: Props = {
  actions: undefined,
  bulkActions: undefined,
  filters: undefined,
  overflow: undefined,
  pageEntries: undefined,
  search: undefined,
  totalEntries: 50
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<TableToolbar {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.restoreAllMocks()
})

it('should work', () => {
  expect(mountWrapper().exists()).toEqual(true)
})

it.todo('should render bulk actions')
it.todo('should render a search bar')
it.todo('should render filter selects')
it.todo('should render left actions')
it.todo('should render right actions')
it.todo('should render a top and bottom pagination')
