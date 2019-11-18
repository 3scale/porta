// @flow

import React from 'react'
import { mount } from 'enzyme'

import { HeaderButton } from 'Policies/components/HeaderButton'

it('should render itself', () => {
  const wrapper = mount(<HeaderButton type='add' onClick={jest.fn()} />)
  expect(wrapper.find(HeaderButton).exists()).toBe(true)
})

it('should handle clicks', () => {
  const spy = jest.fn()
  const wrapper = mount(<HeaderButton type='add' onClick={spy} />)

  wrapper.props().onClick()
  expect(spy).toHaveBeenCalled()
})

it('should have different styles for each type', () => {
  const wrapper = mount(<HeaderButton type='add' onClick={jest.fn()} />)
  expect(wrapper.find('.PolicyChain-addPolicy').exists()).toBe(true)
  expect(wrapper.find('.fa-plus-circle').exists()).toBe(true)

  wrapper.setProps({ type: 'cancel' })
  expect(wrapper.find('.PolicyChain-addPolicy--cancel').exists()).toBe(true)
  expect(wrapper.find('.fa-times-circle').exists()).toBe(true)
})
