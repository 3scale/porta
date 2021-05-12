import React from 'react'
import { mount } from 'enzyme'
import { ListItem } from 'PaymentGateways'

const Child = () => {
  return <p id="child">Hi</p>
}

const props = {
  id: 'my-unique-id',
  children: null
}

it('should render properly', () => {
  const wrapper = mount(<ListItem {...props} />)
  expect(wrapper.exists()).toBe(true)
})

it('should render without children', () => {
  const wrapper = mount(<ListItem {...props} />)
  expect(wrapper.find('#child').exists()).toBe(false)
})

it('should render children', () => {
  const propsChildren = { id: 'my-unique-id', children: <Child /> }
  const wrapper = mount(<ListItem {...propsChildren} />)
  expect(wrapper.find('#child').exists()).toBe(true)
})
