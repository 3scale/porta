import { shallow } from 'enzyme'

import { ServicePlansIndexPage } from 'Plans/components/ServicePlansIndexPage'

import type { Props } from 'Plans/components/ServicePlansIndexPage'

const defaultProps = {
  defaultPlanSelectProps: {
    plans: [],
    initialDefaultPlan: null,
    path: '/path'
  },
  plansTableProps: {
    createButton: undefined,
    columns: [],
    plans: [],
    count: 0,
    searchHref: '/search'
  }
}

const shallowWrapper = (props: Partial<Props> = {}) => shallow(<ServicePlansIndexPage {...{ ...defaultProps, ...props }} />)

it('should render properly', () => {
  const wrapper = shallowWrapper()
  expect(wrapper).toMatchSnapshot()
})
