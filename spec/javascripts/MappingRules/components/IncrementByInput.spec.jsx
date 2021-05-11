// @flow

import React from 'react'
import { mount } from 'enzyme'

import { IncrementByInput } from 'MappingRules'

const defaultProps = {
  increment: 1,
  setIncrement: () => {}
}

const mountWrapper = (props) => mount(<IncrementByInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
