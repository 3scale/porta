// @flow

import React from 'react'
import { mount } from 'enzyme'

import { HttpMethodSelect } from 'MappingRules'

const defaultProps = {
  httpMethod: 'GET',
  httpMethods: ['GET', 'POST'],
  setHttpMethod: () => {}
}

const mountWrapper = (props) => mount(<HttpMethodSelect {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
