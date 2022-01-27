// @flow

import React from 'react'
import { mount } from 'enzyme'

import { PasswordInput } from 'EmailConfigurations/components/form-fields/PasswordInput'

const defaultProps = {
  // props here
}

const mountWrapper = (props) => mount(<PasswordInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
