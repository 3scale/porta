import { shallow } from 'enzyme'

import { ApplicationPlansIndexPage } from 'Plans/components/ApplicationPlansIndexPage'

import type { Props } from 'Plans/components/ApplicationPlansIndexPage'

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

const shallowWrapper = (props: Partial<Props> = {}) => shallow(<ApplicationPlansIndexPage {...{ ...defaultProps, ...props }} />)

it('should render properly', () => {
  const wrapper = shallowWrapper()
  expect(wrapper).toMatchSnapshot()
})
