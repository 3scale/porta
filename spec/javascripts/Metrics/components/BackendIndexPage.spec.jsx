// @flow

import React from 'react'
import { mount } from 'enzyme'

import { BackendIndexPage } from 'Metrics'

const defaultProps = {
  mappingRulesPath: '/mapping-rules'
}

const mountWrapper = (props) => mount(<BackendIndexPage {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
