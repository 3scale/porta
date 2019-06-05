import React from 'react'
import Enzyme, {mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {Login3scaleForm, HiddenInputs} from 'LoginPage'

Enzyme.configure({adapter: new Adapter()})

const props = {
  providerSessionsPath: 'sessions-path'
}

it('should render itself with right props', () => {
  const wrapper = mount(<Login3scaleForm {...props}/>)
  expect(wrapper.find('form#new_session').exists()).toEqual(true)
  expect(wrapper.props().providerSessionsPath).toEqual('sessions-path')
})

it('should render HTML form markup', () => {
  const wrapper = mount(<Login3scaleForm {...props}/>)
  expect(wrapper.find('input#session_username').exists()).toEqual(true)
  expect(wrapper.find('input#session_password').exists()).toEqual(true)
})

it('should render HiddenInputs component', () => {
  const wrapper = mount(<Login3scaleForm {...props}/>)
  expect(wrapper.find(HiddenInputs).exists()).toEqual(true)
})

it('should set username state', () => {
  const wrapper = mount(<Login3scaleForm {...props}/>)
  jest.spyOn(wrapper.instance(), 'handleTextInputUsername')
  wrapper.instance().handleTextInputUsername('foo')
  expect(wrapper.instance().handleTextInputUsername).toHaveBeenCalled()
  expect(wrapper.state().username).toEqual('foo')
})

it('should set password state', () => {
  const wrapper = mount(<Login3scaleForm {...props}/>)
  jest.spyOn(wrapper.instance(), 'handleTextInputPassword')
  wrapper.instance().handleTextInputPassword('bar')
  expect(wrapper.instance().handleTextInputPassword).toHaveBeenCalled()
  expect(wrapper.state().password).toEqual('bar')
})
