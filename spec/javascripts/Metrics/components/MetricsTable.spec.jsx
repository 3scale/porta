// @flow

import React from 'react'
import { mount } from 'enzyme'

// $FlowFixMe[missing-export]
import { MetricsTable } from 'Metrics'

const defaultProps = {
  // props here
}

const mountWrapper = (props) => mount(<MetricsTable {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
