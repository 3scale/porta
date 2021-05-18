// @flow

import React from 'react'
import { mount } from 'enzyme'

import { Select } from 'Common'

const onSelect = jest.fn()
const items = [
  { id: 100, name: 'Mr. Potato' },
  { id: 101, name: 'Budd Lightyear' },
  { id: 102, name: 'Troll' }
]
const defaultProps = {
  item: null,
  items,
  onSelect,
  label: 'Toys',
  fieldId: 'favorite_toy',
  name: 'toy[favorite]',
  placeholderText: 'Select a toy'
}

const mountWrapper = (props) => mount(<Select {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should be able to select an item', () => {
  const wrapper = mountWrapper()

  wrapper.find('.pf-c-select__toggle-button').simulate('click')
  wrapper.find('.pf-c-select__menu-item').first().simulate('click')

  expect(onSelect).toHaveBeenCalledWith(items[0])
})

it('should filter via typeahead', () => {
  const wrapper = mountWrapper()

  wrapper.find('.pf-c-select__toggle-button').simulate('click')
  expect(wrapper.find('ul button').length).toEqual(items.length)

  const input = wrapper.find('.pf-c-select__toggle-typeahead')
  // $FlowIgnore[incompatible-type]
  const inputElement: HTMLInputElement = input.getDOMNode()

  inputElement.value = 'o'
  input.update()
  input.simulate('change')
  expect(wrapper.find('ul button').length).toEqual(2)

  inputElement.value = 'oll'
  input.update()
  input.simulate('change')
  expect(wrapper.find('ul button').length).toEqual(1)

  inputElement.value = 'TROLL'
  input.update()
  input.simulate('change')
  expect(wrapper.find('ul button').length).toEqual(1)
})
