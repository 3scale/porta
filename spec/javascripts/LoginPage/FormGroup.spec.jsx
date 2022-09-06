// @flow

import React from 'react'
import { mount } from 'enzyme'

import { TextField, PasswordField, EmailField } from 'LoginPage'

describe('TextField', () => {
  const textFieldInputProps = {
    isRequired: true,
    isValid: true,
    name: 'text',
    fieldId: 'text',
    label: 'Text Field',
    value: 'Bob Sponge',
    onChange: jest.fn()
  }

  it('should render TextField form group', () => {
    const wrapper = mount(<TextField inputProps={textFieldInputProps}/>)
    expect(wrapper.find('.pf-c-form__group').exists()).toEqual(true)

    expect(wrapper.find('label').length).toEqual(1)
    expect(wrapper.find('label').text()).toMatch('Text Field')

    expect(wrapper.find('input').length).toEqual(1)
    expect(wrapper.find('input').instance()?.type).toEqual('text')
    expect(wrapper.find('input').instance()?.value).toEqual('Bob Sponge')

    expect(wrapper.find('.pf-m-error').exists()).toEqual(false)
  })

  it('should render an error message if not valid', () => {
    const invalidFieldProps = { ...textFieldInputProps, isValid: false }
    const wrapper = mount(<TextField inputProps={invalidFieldProps}/>)
    expect(wrapper.find('.pf-m-error').exists()).toEqual(true)
  })
})

describe('PasswordField', () => {
  const passwordFieldInputProps = {
    isRequired: true,
    isValid: true,
    name: 'password',
    fieldId: 'password',
    label: 'Password',
    value: '12345678',
    onChange: jest.fn()
  }
  it('should render PasswordField form group', () => {
    const wrapper = mount(<PasswordField inputProps={passwordFieldInputProps}/>)
    expect(wrapper.find('.pf-c-form__group').exists()).toEqual(true)

    expect(wrapper.find('label').length).toEqual(1)
    expect(wrapper.find('label').text()).toMatch('Password')

    expect(wrapper.find('input').length).toEqual(1)
    expect(wrapper.find('input').instance()?.type).toEqual('password')
    expect(wrapper.find('input').instance()?.value).toEqual('12345678')

    expect(wrapper.find('.pf-m-error').exists()).toEqual(false)
  })

  it('should render an error message if not valid', () => {
    const invalidFieldProps = { ...passwordFieldInputProps, isValid: false }
    const wrapper = mount(<PasswordField inputProps={invalidFieldProps}/>)
    expect(wrapper.find('.pf-m-error').exists()).toEqual(true)
  })
})

describe('EmailField', () => {
  const emailFieldInputProps = {
    isRequired: true,
    isValid: true,
    name: 'email',
    fieldId: 'email',
    label: 'Email',
    value: 'bob@sponge.com',
    onChange: jest.fn()
  }
  it('should render EmailField form group', () => {
    const wrapper = mount(<EmailField inputProps={emailFieldInputProps}/>)
    expect(wrapper.find('.pf-c-form__group').exists()).toEqual(true)

    expect(wrapper.find('label').length).toEqual(1)
    expect(wrapper.find('label').text()).toMatch('Email')

    expect(wrapper.find('input').length).toEqual(1)
    expect(wrapper.find('input').instance()?.type).toEqual('email')
    expect(wrapper.find('input').instance()?.value).toEqual('bob@sponge.com')

    expect(wrapper.find('.pf-m-error').exists()).toEqual(false)
  })

  it('should render an error message if not valid', () => {
    const invalidFieldProps = { ...emailFieldInputProps, isValid: false }
    const wrapper = mount(<EmailField inputProps={invalidFieldProps}/>)
    expect(wrapper.find('.pf-m-error').exists()).toEqual(true)
  })
})
