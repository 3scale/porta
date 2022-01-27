// @flow

import React from 'react'
import { mount } from 'enzyme'

import { IndexPage } from 'EmailConfigurations/components/IndexPage'

const defaultProps = {
  // props here
}

const mountWrapper = (props) => mount(<IndexPage {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
