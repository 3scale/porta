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
  const event = {
    currentTarget: {
      name: 'username',
      value: 'Bob',
      type: 'text'
    }
  }
  const wrapper = mount(<Login3scaleForm {...props}/>)
  jest.spyOn(wrapper.instance(), 'handleInputChange')
  wrapper.instance().handleInputChange('Bob', event)
  expect(wrapper.instance().handleInputChange).toHaveBeenCalled()
  expect(wrapper.state().username).toEqual('Bob')
})

it('should set password state', () => {
  const event = {
    currentTarget: {
      name: 'password',
      value: 'gary1234',
      type: 'password'
    }
  }
  const wrapper = mount(<Login3scaleForm {...props}/>)
  jest.spyOn(wrapper.instance(), 'handleInputChange')
  wrapper.instance().handleInputChange('gary1234', event)
  expect(wrapper.instance().handleInputChange).toHaveBeenCalled()
  expect(wrapper.state().password).toEqual('gary1234')
})
