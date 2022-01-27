// @flow

import React from 'react'
import { mount } from 'enzyme'

import { UserNameInput } from 'EmailConfigurations/components/form-fields/UserNameInput'

const defaultProps = {
  // props here
}

const mountWrapper = (props) => mount(<UserNameInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
