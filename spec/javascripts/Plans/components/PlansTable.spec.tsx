import { mount } from 'enzyme'

import { PlansTable } from 'Plans/components/PlansTable'

import type { Plan } from 'Types'
import type { Props } from 'Plans/components/PlansTable'

const plans: Plan[] = []
const defaultProps: Props = {
  columns: [],
  onAction: jest.fn(),
  plans,
  count: plans.length,
  searchHref: '/plans'
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<PlansTable {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

it.todo('should render a table with the given columns')
//   const wrapper = mountWrapper()
//   expect(wrapper.find('th')).toMatchSnapshot()
// })
