import React from 'react'
import Enzyme, {mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {RequestPasswordForm, HiddenInputs} from 'LoginPage'

Enzyme.configure({adapter: new Adapter()})

const props = {
  providerLoginPath: 'login-path',
  providerPasswordPath: 'password-path'
}

it('should render itself', () => {
  const wrapper = mount(<RequestPasswordForm {...props}/>)
  expect(wrapper.find('form').exists()).toEqual(true)
  expect(wrapper.props().providerLoginPath).toEqual('login-path')
  expect(wrapper.props().providerPasswordPath).toEqual('password-path')
})

it('should render HTML form markup', () => {
  const wrapper = mount(<RequestPasswordForm {...props}/>)
  expect(wrapper.find('input#email').exists()).toEqual(true)
  expect(wrapper.find('button.pf-c-button').exists()).toEqual(true)
})

it('should render HiddenInputs component', () => {
  const wrapper = mount(<RequestPasswordForm {...props}/>)
  expect(wrapper.find(HiddenInputs).exists()).toEqual(true)
})

it('should set email and validation state to true', () => {
  const event = {
    currentTarget: {
      value: 'bob@sponge.com',
      type: 'email'
    }
  }
  const wrapper = mount(<RequestPasswordForm {...props}/>)
  wrapper.find('input#email').props().onChange(event)
  expect(wrapper.state().email).toEqual('bob@sponge.com')
  expect(wrapper.state('validation').email).toEqual(true)
})

it('should set validation state to false when email is invalid', () => {
  const event = {
    currentTarget: {
      value: 'bobspongecom', 
      type: 'email'
    }
  }
  const wrapper = mount(<RequestPasswordForm {...props}/>)
  wrapper.find('input#email').props().onChange(event)
  expect(wrapper.state().email).toEqual('bobspongecom')
  expect(wrapper.state('validation').email).toEqual(false)
})
