// @flow

import React from 'react'
import { mount } from 'enzyme'

import { EmailInput } from 'EmailConfigurations/components/form-fields/EmailInput'

const defaultProps = {
  // props here
}

const mountWrapper = (props) => mount(<EmailInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
