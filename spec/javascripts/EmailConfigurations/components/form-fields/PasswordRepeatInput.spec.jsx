// @flow

import React from 'react'
import { mount } from 'enzyme'

import { PasswordRepeatInput } from 'EmailConfigurations/components/form-fields/PasswordRepeatInput'

const defaultProps = {
  // props here
}

const mountWrapper = (props) => mount(<PasswordRepeatInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
