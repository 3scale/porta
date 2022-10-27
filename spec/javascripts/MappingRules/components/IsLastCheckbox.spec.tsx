import { mount } from 'enzyme'

import { IsLastCheckbox } from 'MappingRules/components/IsLastCheckbox'

import type { Props } from 'MappingRules/components/IsLastCheckbox'

const defaultProps = {
  isLast: false,
  setIsLast: jest.fn()
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<IsLastCheckbox {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
