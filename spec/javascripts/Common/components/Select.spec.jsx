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
  isClearable: undefined,
  placeholderText: 'Select a toy',
  hint: undefined,
  isValid: undefined,
  helperTextInvalid: undefined,
  isDisabled: undefined,
  isRequired: undefined
}

const mountWrapper = (props) => mount(<Select {...{ ...defaultProps, ...props }} />)

const updateInput = (wrapper, value) => {
  const input = wrapper.find('.pf-c-select__toggle-typeahead')
  // $FlowIgnore[incompatible-type]
  const inputElement: HTMLInputElement = input.getDOMNode()

  inputElement.value = value
  input.update()
  input.simulate('change')
}

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

  updateInput(wrapper, 'o')
  expect(wrapper.find('ul button').length).toEqual(2)

  updateInput(wrapper, 'oll')
  expect(wrapper.find('ul button').length).toEqual(1)

  updateInput(wrapper, 'TROLL')
  expect(wrapper.find('ul button').length).toEqual(1)
})

it('should not be clearable when specified', () => {
  const wrapper = mountWrapper({ isClearable: false })
  expect(wrapper.find('.pf-c-select__toggle-clear').exists()).toBe(false)

  updateInput(wrapper, 'anything')
  // Note the button is still on the DOM, since it's rendered by Patternfly, but hidden by .pf-m-select__toggle-clear-hidden
  expect(wrapper.find('.pf-c-select__toggle-clear').exists()).toBe(true)
  expect(wrapper.find('.pf-m-select__toggle-clear-hidden').exists()).toBe(true)

  wrapper.find('.pf-c-select__toggle-clear').simulate('click')
  expect(onSelect).not.toHaveBeenCalled()

  wrapper.setProps({ isClearable: true })
  updateInput(wrapper, 'anything')
  expect(wrapper.find('.pf-m-select__toggle-clear-hidden').exists()).toBe(false)

  wrapper.find('.pf-c-select__toggle-clear').simulate('click')
  expect(onSelect).toHaveBeenLastCalledWith(null)
})
