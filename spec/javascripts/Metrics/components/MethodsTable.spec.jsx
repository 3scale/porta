// @flow

import React from 'react'
import { mount } from 'enzyme'

import { MethodsTable } from 'Metrics'

const defaultProps = {
  // props here
}

const mountWrapper = (props) => mount(<MethodsTable {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
