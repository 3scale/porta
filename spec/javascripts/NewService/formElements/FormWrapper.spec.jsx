// @flow

import React from 'react'
import Enzyme, {shallow} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {FormWrapper} from 'NewService/components/FormElements'
import {HiddenServiceDiscoveryInput} from 'NewService/components/FormElements'

Enzyme.configure({adapter: new Adapter()})

const submitText = 'Add API'
const props = {
  id: 'form-id',
  formActionPath: 'my-path',
  hasHiddenServiceDiscoveryInput: true,
  submitText
}

it('should render itself', () => {
  const wrapper = shallow(<FormWrapper {...props}/>)
  expect(wrapper.find('#form-id').exists()).toEqual(true)
})

it('should render an empty input', () => {
  const wrapper = shallow(<FormWrapper {...props}/>)
  const input = wrapper.find(`input[name="utf8"][type='hidden']`)
  expect(input.exists()).toBe(true)
})

it('should render submit button with proper text', () => {
  const wrapper = shallow(<FormWrapper {...props}/>)
  const button = wrapper.find(`input[type='submit']`)
  expect(button.exists()).toBe(true)
  expect(button.prop('value')).toEqual(submitText)
})

it('should render a hidden input for service discovery when required', () => {
  const wrapper = shallow(<FormWrapper {...props}/>)

  wrapper.setProps({ hasHiddenServiceDiscoveryInput: false })
  expect(wrapper.find(HiddenServiceDiscoveryInput).exists()).toEqual(false)

  wrapper.setProps({ hasHiddenServiceDiscoveryInput: true })
  expect(wrapper.find(HiddenServiceDiscoveryInput).exists()).toEqual(true)
})

it('should render `CSRFToken` child', () => {
  const wrapper = shallow(<FormWrapper {...props}/>)
  expect(wrapper.find('CSRFToken').exists()).toEqual(true)
})
