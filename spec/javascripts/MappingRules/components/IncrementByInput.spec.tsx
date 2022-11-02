import { mount } from 'enzyme'

import { IncrementByInput } from 'MappingRules/components/IncrementByInput'

import type { Props } from 'MappingRules/components/IncrementByInput'

const defaultProps = {
  increment: 1,
  setIncrement: jest.fn()
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<IncrementByInput {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})
