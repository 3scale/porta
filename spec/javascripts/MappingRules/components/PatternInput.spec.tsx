import React from 'react'
import { mount } from 'enzyme'

import { PatternInput, Props } from 'MappingRules/components/PatternInput'

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
