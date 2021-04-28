// @flow

import React from 'react'
import { mount } from 'enzyme'

import { BackendsUsedListCard } from 'Products'

const defaultProps = {
  backends: []
}

const mountWrapper = (props) => mount(<BackendsUsedListCard {...{ ...defaultProps, ...props }} />)
const mockBackends = (count) => new Array(count).fill({}).map((i, j) => ({ name: `Backend ${j}`, description: `backend_${j}`, href: `/backends/${j}` }))

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should show backends in a table', () => {
  const backends = mockBackends(2)
  const wrapper = mountWrapper({ backends })
  expect(wrapper.find('tbody tr').length).toEqual(backends.length)
})

it('should be paginated and have 5 items per page', () => {
  const backends = mockBackends(6)
  const wrapper = mountWrapper({ backends })
  expect(wrapper.find('tbody tr').length).toEqual(5)

  wrapper.find('.pf-c-pagination button').last().simulate('click')
  expect(wrapper.find('tbody tr').length).toEqual(1)
})

// FIXME: input not receiving change event
it.skip('should be filterable by name', () => {
  const Items = mockBackends(10)
  const wrapper = mountWrapper({ Items })

  wrapper.find('input[type="search"]').simulate('change', { target: { value: '1' } })
  wrapper.find('.pf-c-input-group button').last().simulate('click')
  wrapper.update()

  expect(wrapper.find('tbody tr').length).toEqual(2)
})

// FIXME: input not receiving change event
it.skip('should search when pressing Enter', () => {
  const Items = mockBackends(10)
  const wrapper = mountWrapper({ Items })

  wrapper.find('input[type="search"]').simulate('change', { target: { value: '1' } })
  wrapper.find('input[type="search"]').simulate('keydown', { key: 'Enter' })
  wrapper.update()

  expect(wrapper.find('tbody tr').length).toEqual(2)
})
