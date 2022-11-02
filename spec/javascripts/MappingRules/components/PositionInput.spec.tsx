import { mount } from 'enzyme'

import { PositionInput } from 'MappingRules/components/PositionInput'

import type { Props } from 'MappingRules/components/PositionInput'

const defaultProps = {
  position: 0,
  setPosition: jest.fn()
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<PositionInput {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})
