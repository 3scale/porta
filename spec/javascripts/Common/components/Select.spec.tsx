import { mount } from 'enzyme'

import { Select } from 'Common/components/Select'
import { updateInput } from 'utilities/test-utils'

import type { Props } from 'Common/components/Select'
import type { IRecord } from 'Types'

const onSelect = jest.fn()
const items = [
  { id: 100, name: 'Mr. Potato' },
  { id: 101, name: 'Budd Lightyear' },
  { id: 102, name: 'Troll' }
]
const defaultProps: Props<IRecord> = {
  item: null,
  items,
  onSelect,
  label: <h1>Toys</h1>,
  'aria-label': 'Toys',
  fieldId: 'favorite_toy',
  name: 'toy[favorite]',
  isClearable: undefined,
  placeholderText: 'Select a toy',
  hint: undefined,
  validated: undefined,
  helperText: undefined,
  helperTextInvalid: undefined,
  isDisabled: undefined,
  isLoading: undefined,
  isRequired: undefined
}

const mountWrapper = (props: Partial<Props<IRecord>> = {}) => mount(<Select {...{ ...defaultProps, ...props }} />)

beforeEach(() => onSelect.mockReset())

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
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
  expect(wrapper.exists(`[aria-label="${defaultProps['aria-label']!}"]`)).toEqual(true)
})

it('should show a spinner when loading', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists('Spinner')).toEqual(false)

  wrapper.setProps({ isLoading: true })
  expect(wrapper.exists('Spinner')).toEqual(true)
})

it('should clear the selection only when clearable', () => {
  const wrapper = mountWrapper({ item: items[0], isClearable: false })
  const clearButton = () => wrapper.find('[aria-label="Clear all"]')

  expect(clearButton().exists()).toEqual(false)

  wrapper.setProps({ item: items[0], isClearable: undefined })
  clearButton().simulate('click')
  expect(onSelect).toHaveBeenCalledWith(null)
})
