// @flow

import React from 'react'
import { mount } from 'enzyme'

import { EmailConfigurationForm } from 'EmailConfigurations/components/EmailConfigurationForm'

const defaultProps = {
  // props here
}

const mountWrapper = (props) => mount(<EmailConfigurationForm {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
