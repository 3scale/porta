import React from 'react'
import { mount } from 'enzyme'

import { Select } from 'Common'
import { updateInput } from 'utilities/test-utils'

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
  label: <h1>Toys</h1>,
  ariaLabel: 'Toys',
  fieldId: 'favorite_toy',
  name: 'toy[favorite]',
  isClearable: undefined,
  placeholderText: 'Select a toy',
  hint: undefined,
  isValid: undefined,
  helperText: undefined,
  helperTextInvalid: undefined,
  isDisabled: undefined,
  isLoading: undefined,
  isRequired: undefined
} as const

const mountWrapper = (props) => mount(<Select {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should have a hidden input for the selected item', () => {
  const item = items[0]
  const wrapper = mountWrapper({ item })
  expect(wrapper.find('input[type="hidden"]').prop('value')).toEqual(item.id)
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

it('should be aria-labelled', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find(`[aria-label="${defaultProps.ariaLabel}"]`).exists()).toBe(true)
})

it('should show a spinner when loading', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('Spinner').exists()).toBe(false)

  wrapper.setProps({ isLoading: true })
  expect(wrapper.find('Spinner').exists()).toBe(true)
})

it('should clear the selection only when clearable', () => {
  const wrapper = mountWrapper({ item: items[0], isClearable: false })
  const clearButton = () => wrapper.find('[aria-label="Clear all"]')

  expect(wrapper.find('.pf-m-select__toggle-clear-hidden').exists()).toBe(true)
  // Note the button is still on the DOM, since it's rendered by Patternfly, but hidden by .pf-m-select__toggle-clear-hidden
  clearButton().simulate('click')
  expect(onSelect).not.toHaveBeenCalled()

  wrapper.setProps({ item: items[0], isClearable: true })
  expect(wrapper.find('.pf-m-select__toggle-clear-hidden').exists()).toBe(false)
  clearButton().simulate('click')
  expect(onSelect).toHaveBeenCalledWith(null)
})
