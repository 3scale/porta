import { mount } from 'enzyme'

import { FormLegend } from 'Settings/components/Common/FormLegend'

import type { Props } from 'Settings/components/Common/FormLegend'

const defaultProps: Props = {}

const mountWrapper = (props: Partial<Props> = {}) => mount(
  <FormLegend {...{ ...defaultProps, ...props }} />
)

it('should render correctly', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists('.pf-c-form__legend')).toEqual(true)

  wrapper.setProps({ className: 'banana' })
  expect(wrapper.exists('.pf-c-form__legend.banana')).toEqual(true)
})
