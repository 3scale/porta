import { shallow } from 'enzyme'

import { IndexPageMainSection } from 'Plans/components/IndexPageMainSection'

import type { Props } from 'Plans/components/IndexPageMainSection'

const defaultProps: Props = {
  helperText: undefined,
  defaultPlanSelectProps: {
    plans: [],
    initialDefaultPlan: null,
    path: '/path'
  },
  plansTableProps: {
    createButton: undefined,
    columns: [],
    plans: [],
    count: 0
  }
}

const shallowWrapper = (props: Partial<Props> = {}) => shallow(<IndexPageMainSection {...{ ...defaultProps, ...props }} />)

it('should render properly', () => {
  const wrapper = shallowWrapper()
  expect(wrapper).toMatchSnapshot()
})

it('should render a helperText', () => {
  const wrapper = shallowWrapper({ helperText: 'This is a helper text' })
  expect(wrapper).toMatchSnapshot()
})
