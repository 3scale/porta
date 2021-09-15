// @flow

import React from 'react'
import { mount } from 'enzyme'
import type { ReactWrapper } from 'enzyme'

import { SelectWithModal } from 'Common'

const onSelect = jest.fn()
const fetchItems = jest.fn()
const onAbortFetch = jest.fn()

const cells = [
  { propName: 'name', title: 'Name' },
  { propName: 'role', title: 'Role' }
]

const items = [
  { id: 0, name: 'J. Holden', role: 'Captain' },
  { id: 1, name: 'N. Nagata', role: 'Engineer' },
  { id: 2, name: 'A. Kamal', role: 'Pilot' }
]

const title = 'Select a crew member'

const defaultProps = {
  label: 'Label',
  fieldId: 'fieldId',
  id: 'id',
  name: 'name',
  item: null,
  items,
  itemsCount: items.length,
  cells,
  onSelect,
  header: 'Header',
  isDisabled: undefined,
  title,
  placeholder: 'Placeholder',
  footerLabel: 'Footer Label',
  fetchItems,
  onAbortFetch
}

// $FlowIgnore[incompatible-type] ignore fetchItems implementation
const mountWrapper = (props) => mount(<SelectWithModal {...{ ...defaultProps, ...props }} />)

function openModal <T> (wrapper: ReactWrapper<T>) {
  // HACK: suppress error logs during this step cause wrapping it inside act() makes the test fail
  const spy = jest.spyOn(console, 'error')
  spy.mockImplementation(() => {})

  wrapper.find('.pf-c-select__toggle-button').simulate('click')
  wrapper.find('.pf-c-select__menu li button.pf-c-select__menu-item--sticky-footer').last().simulate('click')

  spy.mockClear()
}

function closeModal <T> (wrapper: ReactWrapper<T>) {
  wrapper.find(`.pf-c-modal-box[aria-label="${title}"]`).find('.pf-c-button[aria-label="Close"]').simulate('click')
}

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should be able to select an item', () => {
  const targetItem = items[0]
  const wrapper = mountWrapper()

  wrapper.find('.pf-c-select__toggle-button').simulate('click')
  wrapper.find('.pf-c-select__menu li button').filterWhere(n => n.text().includes(targetItem.name)).simulate('click')

  expect(onSelect).toBeCalledWith(targetItem)
})

describe('with 20 items or less', () => {
  const items = new Array(20).fill({}).map((i, j) => ({ id: j, name: `Mr. ${j}` }))
  const props = {
    items,
    itemsCount: items.length
  }

  it('should display all items and a title, but no sticky footer', () => {
    const wrapper = mountWrapper(props)
    wrapper.find('.pf-c-select__toggle-button').simulate('click')
    expect(wrapper.find('.pf-c-select__menu li').length).toEqual(items.length + 1)
  })

  it('should not be able to show a modal', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.find('PaginatedTableModal').exists()).toBe(false)
  })
})

describe('with more than 20 items', () => {
  const items = new Array(25).fill({}).map((i, j) => ({ id: j, name: `Mr. ${j}` }))
  const props = {
    items,
    itemsCount: items.length
  }

  it('should display up to 20 items, a title and a sticky footer', () => {
    const wrapper = mountWrapper(props)
    wrapper.find('.pf-c-select__toggle-button').simulate('click')
    expect(wrapper.find('.pf-c-select__menu li')).toHaveLength(22)
  })

  it('should be able to show a modal', () => {
    const wrapper = mountWrapper(props)

    expect(wrapper.find('PaginatedTableModal').props().isOpen).toBe(false)

    openModal(wrapper)
    expect(wrapper.find('PaginatedTableModal').props().isOpen).toBe(true)
    expect(onSelect).toBeCalledTimes(0)
  })

  it('should be able to select an option from the modal', () => {
    const wrapper = mountWrapper(props)

    openModal(wrapper)
    wrapper.find('input[type="radio"]').first().simulate('change', { value: true })
    wrapper.find('button[data-testid="select"]').simulate('click')

    expect(onSelect).toHaveBeenCalledWith(items[0])
  })

  it('should display all columns in the modal', () => {
    const wrapper = mountWrapper(props)

    openModal(wrapper)
    const ths = wrapper.find('table th')

    cells.forEach(c => (
      expect(ths.find(`[data-label="${c.title}"]`).exists()).toBe(true)
    ))
  })

  // FIXME: simulate change
  it.skip('should be able to search an item by name', () => {
    const wrapper = mountWrapper(props)

    openModal(wrapper)
    wrapper.find('input[type="search"]').simulate('change', { value: 'pepe' })
    expect(fetchItems).toHaveBeenCalledTimes(1)
    expect(fetchItems).toHaveBeenCalledWith(expect.objectContaining({ query: 'pepe' }))
  })

  describe('when there are remote items that have not been fetched', () => {
    const props = {
      items: [],
      itemsCount: 30
    }

    it('should fetch more items', async () => {
      fetchItems.mockResolvedValue({ items, count: 30 })
      const wrapper = mountWrapper(props)
      openModal(wrapper)
      expect(fetchItems).toHaveBeenCalledTimes(1)
      expect(fetchItems).toHaveBeenCalledWith({ page: 1, perPage: 5 })
    })

    it('should abort the ongoing fetch when modal closed', () => {
      fetchItems.mockResolvedValue({ items, count: 30 })
      const wrapper = mountWrapper(props)
      openModal(wrapper)
      closeModal(wrapper)
      expect(fetchItems).toHaveBeenCalledTimes(1)
      expect(onAbortFetch).toHaveBeenCalledTimes(1)
    })
  })
})

describe('with no items', () => {
  const props = {
    items: [],
    itemsCount: 0
  }

  it('should show an empty message that is disabled', () => {
    const wrapper = mountWrapper(props)
    wrapper.find('.pf-c-select__toggle-button').simulate('click')

    const items = wrapper.find('SelectOption')
    expect(items.length).toEqual(2)

    const emptyItem = items.last()
    expect(emptyItem.prop('isDisabled')).toBe(true)
    expect(emptyItem.text()).toEqual('No results found')
  })
})
