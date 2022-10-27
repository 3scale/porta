import React from 'react'
import { mount } from 'enzyme'
import { Label } from 'PaymentGateways'

const props = {
  htmlFor: 'username',
  label: 'Username',
  required: false
}

it('should render properly', () => {
  const wrapper = mount(<Label {...props} />)
  expect(wrapper.exists()).toBe(true)
})

it('should render label', () => {
  const wrapper = mount(<Label {...props} />)
  expect(wrapper.text()).toEqual('Username')
})

it('should add * to mandatory field', () => {
  const propsRequired = { ...props, required: true }
  const wrapper = mount(<Label {...propsRequired} />)
  expect(wrapper.text()).toEqual('Username *')
})
