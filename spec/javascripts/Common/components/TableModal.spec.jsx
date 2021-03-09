// @flow

import React from 'react'
import { mount } from 'enzyme'

import { TableModal } from 'Common'

const onSelectSpy = jest.fn()
const onCloseSpy = jest.fn()

const cells = [
  { title: 'Name', propName: 'name' },
  { title: 'Role', propName: 'role' }
]

const crew = [
  { id: 0, name: 'J. Holden', role: 'Captain' },
  { id: 1, name: 'A. Burton', role: 'Muscle' }
]

const defaultProps = {
  title: 'The Rocinante',
  item: null,
  items: crew,
  onSelect: onSelectSpy,
  onClose: onCloseSpy,
  cells,
  isOpen: true
}

const mountWrapper = (props) => mount(<TableModal {...{ ...defaultProps, ...props }} />)

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
  expect(wrapper.find('tbody tr').length).toEqual(crew.length)
  expect(wrapper.find('.pf-c-pagination__nav button[data-action="next"]').first().prop('disabled')).toBe(true)
})

it('should have a paginated table', () => {
  const items = new Array(10).fill({}).map((_n, i) => ({
    id: i,
    name: `Name ${i}`,
    role: `Mate ${i}`
  }))
  const perPage = 4
  const wrapper = mountWrapper({ items, perPage })

  const pages = Math.ceil(items.length / perPage)

  let topPagination = wrapper.find('.pf-c-pagination__nav-page-select').first()
  expect(topPagination.find('input').prop('value')).toEqual(1)
  expect(topPagination.text()).toEqual(`of ${pages}`)

  const rows = wrapper.find('tbody tr')
  expect(rows.length).toEqual(perPage)

  const buttonNext = wrapper.find('.pf-c-pagination__nav button[data-action="next"]').first()
  expect(buttonNext.prop('disabled')).toBe(false)
  buttonNext.simulate('click')

  topPagination = wrapper.find('.pf-c-pagination__nav-page-select').first()
  expect(topPagination.find('input').prop('value')).toEqual(2)
})

it.skip('should have a filterable table', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('tbody tr').length).toEqual(crew.length)

  const textInput = wrapper.find('.pf-c-toolbar input[type="search"]')
  // FIXME: input not receiving text for some reason
  textInput.simulate('change', { target: { value: 'Kamal' } })
  expect(wrapper.find('.pf-c-toolbar input[type="search"]').text()).toEqual('Kamal')

  const searchButton = wrapper.find('button[data-testid="search"]')
  searchButton.simulate('click')
  expect(wrapper.update().find('tbody tr').length).toEqual(0)
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

it('should be able to select an item', () => {
  const item = { id: 0, name: 'N. Nagata', role: 'Engineer' }
  const wrapper = mountWrapper({ items: [item] })

  const radio = wrapper.find('tbody tr').first().find('input')
  radio.simulate('change', { currentTarget: { checked: true } })

  wrapper.find('button[data-testid="select"]').simulate('click')
  expect(onSelectSpy).toHaveBeenCalledWith(item)
})

it('should be cancelable', () => {
  const wrapper = mountWrapper()
  wrapper.find('button[data-testid="cancel"]').simulate('click')
  expect(onCloseSpy).toHaveBeenCalledTimes(1)
})

it('should check the current item if previously selected', () => {
  const item = { id: 0, name: 'N. Nagata', role: 'Engineer' }
  const wrapper = mountWrapper({ items: [item], item })

  const radio = wrapper.find('tbody tr').first().find('input')
  expect(radio.prop('checked')).toBe(true)
})
