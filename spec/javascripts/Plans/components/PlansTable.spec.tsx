import { mount } from 'enzyme'

import { PlansTable, Props } from 'Plans/components/PlansTable'

const plans: Array<never> = []
const defaultProps: Props = {
  columns: [],
  onAction: jest.fn(),
  plans,
  count: plans.length,
  searchHref: '/plans'
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<PlansTable {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it.todo('should render a table with the given columns')
// it('should render a table with Name, Applications and State', () => {
//   const wrapper = mountWrapper()
//   expect(wrapper.find('th')).toMatchSnapshot()
// })
