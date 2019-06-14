import React from 'react'
import Enzyme, {mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {FormGroup} from 'LoginPage'

Enzyme.configure({adapter: new Adapter()})
const props = {
  type: 'username',
  labelIsValid: true,
  inputProps: {
    value: 'username',
    onChange: jest.fn(),
    autoFocus: 'autoFocus',
    inputIsValid: true,
    ariaInvalid: true
  }
}

it('should render username Form Group', () => {
  const wrapper = mount(<FormGroup {...props}/>)
  expect(wrapper.find('.pf-c-form__group').exists()).toEqual(true)
  expect(wrapper.find('label').length).toEqual(1)
  expect(wrapper.find('label').contains('Email or Username')).toEqual(true)
  expect(wrapper.find('input').instance().type).toEqual('text')
})

it('should render password Form Group', () => {
  const propsPassword = {...props, type: 'password'}
  const wrapper = mount(<FormGroup {...propsPassword}/>)
  expect(wrapper.find('.pf-c-form__group').exists()).toEqual(true)
  expect(wrapper.find('label').contains('Password')).toEqual(true)
  expect(wrapper.find('input').instance().type).toEqual('password')
})

it('should render email Form Group', () => {
  const propsPassword = {...props, type: 'email'}
  const wrapper = mount(<FormGroup {...propsPassword}/>)
  expect(wrapper.find('.pf-c-form__group').exists()).toEqual(true)
  expect(wrapper.find('label').contains('Email address')).toEqual(true)
  expect(wrapper.find('input').instance().type).toEqual('email')
})
