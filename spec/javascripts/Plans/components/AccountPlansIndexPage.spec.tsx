import { shallow } from 'enzyme'

import { AccountPlansIndexPage } from 'Plans/components/AccountPlansIndexPage'

import type { Props } from 'Plans/components/AccountPlansIndexPage'

const defaultProps = {
  showNotice: true,
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

const shallowWrapper = (props: Partial<Props> = {}) => shallow(<AccountPlansIndexPage {...{ ...defaultProps, ...props }} />)

it('should show a notice', () => {
  const wrapper = shallowWrapper({ showNotice: false })
  expect(wrapper).toMatchSnapshot()

  wrapper.setProps({ showNotice: true })
  expect(wrapper).toMatchSnapshot()
})
