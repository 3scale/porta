// @flow

import React from 'react'
import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { ApplicationPlansTableCard } from 'Plans'

const fetch = jest.fn()
fetch.mockResolvedValue({ status: 200 })
global.fetch = fetch

const consoleSpy = jest.fn()
// $FlowExpectedError[cannot-write] suppress error logs during test
console.error = consoleSpy

const actions = [
  { title: 'Copy', path: '/copy', method: 'POST' },
  { title: 'Publish', path: '/publish', method: 'POST' },
  { title: 'Hide', path: '/hide', method: 'POST' },
  { title: 'Delete', path: '/delete', method: 'POST' }
]

const plans = [{ id: 0, name: 'Basic Plan', actions, applications: 0, state: 'state', editPath: '/edit', applicationsPath: '/apps' }]
const defaultProps = {
  plans,
  count: plans.length,
  searchHref: '/plans'
}

const mountWrapper = (props) => mount(<ApplicationPlansTableCard {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.clearAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should be able to copy a plan', async () => {
  const wrapper = mountWrapper()

  wrapper.find('.pf-c-dropdown__toggle').simulate('click')
  await act(async () => {
    wrapper.find('button')
      .findWhere(b => b.text() === 'Copy')
      .find('button')
      .simulate('click')
  })

  expect(fetch).toHaveBeenCalledWith('/copy', expect.objectContaining({ method: 'POST' }))
})

it('should be able to publish a plan', async () => {
  const wrapper = mountWrapper()

  wrapper.find('.pf-c-dropdown__toggle').simulate('click')
  await act(async () => {
    wrapper.find('button')
      .findWhere(b => b.text() === 'Publish')
      .find('button')
      .simulate('click')
  })

  expect(fetch).toHaveBeenCalledWith('/publish', expect.objectContaining({ method: 'POST' }))
})

it('should be able to hide a plan', async () => {
  const wrapper = mountWrapper()

  wrapper.find('.pf-c-dropdown__toggle').simulate('click')
  await act(async () => {
    wrapper.find('button')
      .findWhere(b => b.text() === 'Hide')
      .find('button')
      .simulate('click')
  })

  expect(fetch).toHaveBeenCalledWith('/hide', expect.objectContaining({ method: 'POST' }))
})

it('should be able to delete a plan after user confirmation', async () => {
  const windownConfirmMock = jest.fn()
  window.confirm = windownConfirmMock.mockResolvedValueOnce(true)

  const wrapper = mountWrapper()

  wrapper.find('.pf-c-dropdown__toggle').simulate('click')
  await act(async () => {
    wrapper.find('button')
      .findWhere(b => b.text() === 'Delete')
      .find('button')
      .simulate('click')
  })

  expect(fetch).toHaveBeenCalledWith('/delete', expect.objectContaining({ method: 'DELETE' }))
})

it('should log an error if an action is unknown', () => {
  const action = { title: 'Unknown Action', path: '/actions/A', method: 'POST' }

  const wrapper = mountWrapper({ plans: [{ ...plans[0], id: 0, name: 'Basic Plan', actions: [action] }] })

  wrapper.find('.pf-c-dropdown__toggle').simulate('click')
  wrapper.find('button')
    .findWhere(b => b.text() === action.title)
    .find('button')
    .simulate('click')

  expect(consoleSpy).toHaveBeenLastCalledWith(`Unknown action: ${action.title}`)
})
