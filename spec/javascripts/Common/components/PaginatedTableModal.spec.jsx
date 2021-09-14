// @flow

import React from 'react'
import { mount } from 'enzyme'

import { PaginatedTableModal } from 'Common'

const onSelectSpy = jest.fn()
const onCloseSpy = jest.fn()
const setPageSpy = jest.fn()
const onSearchSpy = jest.fn()
const searchInputRef: {| current: HTMLInputElement | null |} = {
  // $FlowIgnore[incompatible-type]
  current: jest.fn()
}

const cells = [
  { title: 'Name', propName: 'name' }
]

const collection = new Array(11).fill({}).map((_, j) => ({ id: j, name: `Item ${j}` }))
const perPage = 5
const pageItems = collection.slice(0, perPage)

const defaultProps = {
  title: 'The Paginated Table Modal',
  selectedItem: null,
  pageItems,
  onSelect: onSelectSpy,
  onClose: onCloseSpy,
  onSearch: onSearchSpy,
  searchInputRef,
  cells,
  isOpen: true,
  isLoading: false,
  itemsCount: collection.length,
  perPage,
  page: 1,
  setPage: setPageSpy,
  sortBy: { index: 1, direction: 'desc' }
}

const mountWrapper = (props) => mount(<PaginatedTableModal {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper({ isOpen: true })
  expect(wrapper.exists()).toBe(true)
})

it('should be hidden by default', () => {
  const wrapper = mountWrapper({ isOpen: undefined })
  expect(wrapper.html()).toBe('')
})

it('should render a table when open', () => {
  const wrapper = mountWrapper({ isOpen: true })
  expect(wrapper.find('table').exists()).toBe(true)
  expect(wrapper.find('h1').text()).toMatch(defaultProps.title)
  cells.forEach(c => {
    expect(wrapper.find('th').findWhere(th => th.text() === c.title).exists()).toBe(true)
  })
  expect(wrapper.find('tbody tr').length).toEqual(pageItems.length)
})

it('should be closeable', () => {
  const wrapper = mountWrapper()
  wrapper.find('button[aria-label="Close"]').simulate('click')
  expect(onCloseSpy).toHaveBeenCalledTimes(1)
})

it('should disable the select button until an item is selected', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('button[data-testid="select"]').prop('disabled')).toBe(true)

  const radio = wrapper.find('tbody tr').first().find('input')
  radio.simulate('change', { currentTarget: { checked: true } })

  expect(wrapper.find('button[data-testid="select"]').prop('disabled')).toBe(false)
})

it('should be cancelable', () => {
  const wrapper = mountWrapper()
  wrapper.find('button[data-testid="cancel"]').simulate('click')
  expect(onCloseSpy).toHaveBeenCalledTimes(1)
})

it.todo('should have a paginated table')
it.todo('should have a filterable table')
it.todo('should be able to select an item')
it.todo('should check the current item if previously selected')

describe.skip('when the whole collection is local', () => {
  it.todo('should not fetch any more items')
})

describe.skip('when the collection is too big to be local', () => {
  it.todo('should fetch for items of empty pages')
})
