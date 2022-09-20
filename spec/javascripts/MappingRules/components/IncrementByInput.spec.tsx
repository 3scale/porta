import React from 'react'
import { mount } from 'enzyme'

import { IncrementByInput, Props } from 'MappingRules/components/IncrementByInput'

const defaultProps = {
  increment: 1,
  setIncrement: jest.fn()
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<IncrementByInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
