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

it('should set emailAddress state', () => {
  const event = {
    currentTarget: {
      value: 'bob@sponge.com',
      type: 'email'
    }
  }
  const wrapper = mount(<RequestPasswordForm {...props}/>)
  jest.spyOn(wrapper.instance(), 'handleTextInputEmail')
  wrapper.instance().handleTextInputEmail('bob@sponge.com', event)
  expect(wrapper.instance().handleTextInputEmail).toHaveBeenCalled()
  expect(wrapper.state().email).toEqual('bob@sponge.com')
})
