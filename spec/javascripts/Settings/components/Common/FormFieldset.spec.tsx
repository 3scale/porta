import { mount } from 'enzyme'

import { FormFieldset } from 'Settings/components/Common/FormFieldset'

import type { Props } from 'Settings/components/Common/FormFieldset'

const defaultProps: Props = {}

const mountWrapper = (props: Partial<Props> = {}) => mount(
  <FormFieldset {...{ ...defaultProps, ...props }}>
    <div id="child">The Child</div>
  </FormFieldset>
)

it('should render correctly', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists('#child')).toEqual(true)
})

it('should render a class', () => {
  const wrapper = mountWrapper({ className: 'pepe banana' })
  expect(wrapper.exists('.pepe.banana')).toEqual(true)
})
