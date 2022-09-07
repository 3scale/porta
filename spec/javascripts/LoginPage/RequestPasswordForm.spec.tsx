import React from 'react';
import {mount} from 'enzyme'

import { RequestPasswordForm } from 'LoginPage'

const props = {
  flashMessages: [],
  providerLoginPath: 'login-path',
  providerPasswordPath: 'password-path'
} as const

it('should render itself', () => {
  const wrapper = mount(<RequestPasswordForm {...props}/>)
  expect(wrapper).toMatchSnapshot()
})

it('should render flashMessages when present', () => {
  const propsWithFlashMessages = {
    ...props,
    flashMessages: [{ message: 'Ooops', type: 'error' }]
  } as const
  const wrapper = mount(<RequestPasswordForm {...propsWithFlashMessages}/>)
  expect(wrapper).toMatchSnapshot()
})

it('should set email and validation state to true', () => {
  const event = {
    currentTarget: {
      value: 'bob@sponge.com',
      type: 'email'
    }
  } as const
  const wrapper = mount(<RequestPasswordForm {...props}/>)
  wrapper.find('input#email').props().onChange(event)
  expect(wrapper.state().email).toEqual('bob@sponge.com')
  expect(wrapper.state().validation.email).toEqual(true)
})

it('should set validation state to false when email is invalid', () => {
  const event = {
    currentTarget: {
      value: 'bobspongecom',
      type: 'email'
    }
  } as const
  const wrapper = mount(<RequestPasswordForm {...props}/>)
  wrapper.find('input#email').props().onChange(event)
  expect(wrapper.state().email).toEqual('bobspongecom')
  expect(wrapper.state().validation.email).toEqual(false)
})
