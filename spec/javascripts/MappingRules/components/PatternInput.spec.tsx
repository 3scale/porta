import { mount } from 'enzyme'
import { PatternInput } from 'MappingRules/components/PatternInput'

import type { Props } from 'MappingRules/components/PatternInput'

const defaultProps: Props = {
  pattern: '',
  validatePattern: jest.fn(),
  validated: 'default',
  helperTextInvalid: ''
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<PatternInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
