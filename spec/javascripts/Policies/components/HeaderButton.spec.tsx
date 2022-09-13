import React from 'react'
import { render, mount } from 'enzyme'

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

it('should be able to render an "add" button variant', () => {
  const wrapper = render(<HeaderButton type='add' onClick={jest.fn()} />)
  expect(wrapper).toMatchSnapshot()
})

it('should be able to render a "cancel" button variant', () => {
  const wrapper = render(<HeaderButton type='cancel' onClick={jest.fn()} />)
  expect(wrapper).toMatchSnapshot()
})
