// @flow

import React from 'react'
import { mount } from 'enzyme'

import { SelectWithModal } from 'Common'

const onClose = jest.fn()
const onSelect = jest.fn()

const cells = [{
  propName: 'name', title: 'Name'
}]

const item = { id: 0, name: 'My Backend', description: 'example.org' }
const defaultProps = {
  item: null,
  items: [item],
  onClose,
  onSelect,
  isOpen: true,
  helperText: '',
  id: '',
  label: '',
  modalTitle: 'Modal',
  name: 'Name',
  cells
  // TODO
}

// $FlowFixMe $FlowIssue It should not complain since Record.id has union "number | string"
const mountWrapper = (props) => mount(<SelectWithModal {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it.skip('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should display all items, a title and a sticky button', () => {
  const wrapper = mountWrapper()
  wrapper.find('.pf-c-select__toggle-button').simulate('click')
  expect(wrapper.find('.pf-c-select__menu li').length).toEqual(backends.length + 2)
})

it('should be able to show a modal', () => {
  const wrapper = mountWrapper()

  wrapper.find('.pf-c-select__toggle-button').simulate('click')
  wrapper.find('.pf-c-select__menu li button').last().simulate('click')

  expect(onShowAllSpy).toBeCalledTimes(1)
  expect(onSelectSpy).toBeCalledTimes(0)
})

it('should be able to select and submit an item', () => {
  const targetItem = backends[0]
  const wrapper = mountWrapper()

  wrapper.find('.pf-c-select__toggle-button').simulate('click')
  wrapper.find('.pf-c-select__menu li button').filterWhere(n => n.text().includes(targetItem.name)).simulate('click')

  expect(onSelectSpy).toBeCalledWith(targetItem)
})

it('should be able to submit the selected backend', () => {
  const targetItem = backends[0]
  const wrapper = mountWrapper({ backend: targetItem })

  const input = wrapper.find('[name="backend_api_config[backend_api_id]"]')
  expect(input.exists()).toBe(true)
  expect(input.prop('value')).toBe(targetItem.id)
})

it('should have a button to create a new backend', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find(`a[href="${newBackendPath}"]`))
})

it.skip('should be able to select an option', () => {
  const wrapper = mountWrapper()
  wrapper.find('input[type="radio"]').simulate('change', { value: true })
  wrapper.find('button[data-testid="select"]').simulate('click')
  expect(onSelect).toHaveBeenCalledWith(item)
})
