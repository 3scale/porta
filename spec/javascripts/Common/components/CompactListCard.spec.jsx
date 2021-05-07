// @flow

import React from 'react'
import { mount } from 'enzyme'

import { CompactListCard } from 'Common'

const onSearch = jest.fn()
const setPage = jest.fn()
const searchInputRef: {| current: HTMLInputElement | null |} = {
  // $FlowIgnore[incompatible-type]
  current: jest.fn()
}
const item = { name: 'Item Name', href: '/item/href', description: 'Item description' }
const defaultProps = {
  columns: ['Col A', 'Col B'],
  items: [item],
  searchInputRef,
  onSearch,
  page: 1,
  setPage,
  perPage: 5,
  searchInputPlaceholder: 'Search',
  tableAriaLabel: 'Table'
}

const mountWrapper = (props) => mount(<CompactListCard {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should not render a table header', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('th').exists()).toBe(false)
})

it('should render each row with a link to the item and a description', () => {
  const wrapper = mountWrapper()
  const rows = wrapper.find('table td')
  expect(rows.findWhere(n => n.text() === item.name).exists()).toBe(true)
  expect(rows.find(`a[href="${item.href}"]`).exists()).toBe(true)
  expect(rows.findWhere(n => n.text() === item.description).exists()).toBe(true)
})
