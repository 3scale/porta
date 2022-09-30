import { mount } from 'enzyme'

import { PositionInput, Props } from 'MappingRules/components/PositionInput'

const defaultProps = {
  position: 0,
  setPosition: jest.fn()
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<PositionInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
