import React from 'react'
import { mount } from 'enzyme'

import { PatternInput } from 'MappingRules'

const defaultProps = {
  pattern: '',
  validatePattern: () => {},
  validated: 'default',
  helperTextInvalid: ''
} as const

const mountWrapper = (props: undefined) => mount(<PatternInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
