import React from 'react'
import { mount } from 'enzyme'

import { PasswordRepeatInput, Props } from 'EmailConfigurations/components/form-fields/PasswordRepeatInput'

const setPassword = jest.fn()
const defaultProps = {
  password: '',
  setPassword,
  errors: []
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<PasswordRepeatInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should not be submitted', () => {
  const wrapper = mountWrapper()
  const input = wrapper.find('input[name="email_configuration[password]"]')
  expect(input.exists()).toBe(false)
})

it('should work', () => {
  const value = 'dragonhe@rtsstringFTW1909'
  const wrapper = mountWrapper()

  const input = wrapper.find('input#email_configuration_password_repeat')
  input.simulate('change', { currentTarget: { value } })

  expect(setPassword).toHaveBeenCalledTimes(1)
})

it('should render errors', () => {
  const errors = ['Wrong this', 'Wrong that']
  const wrapper = mountWrapper({ errors })

  expect(wrapper.find('.pf-m-error').text()).toEqual('Wrong this,Wrong that')
})
