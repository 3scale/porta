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
  const wrapper = mount(<RequestPasswordForm {...props}/>)
  const event = {
    currentTarget: {
      id: 'email'
    }
  }
  jest.spyOn(wrapper.instance(), 'handleTextInputEmail')
  wrapper.instance().handleTextInputEmail('foo@bar.com', event)
  expect(wrapper.instance().handleTextInputEmail).toHaveBeenCalled()
  expect(wrapper.state().emailAddress).toEqual('foo@bar.com')
})
