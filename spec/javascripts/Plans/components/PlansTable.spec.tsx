/* eslint-disable @typescript-eslint/require-await -- This is required for the "simulate click" part. Otherwise the tests won't pass */
import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { PlansTable } from 'Plans/components/PlansTable'

import type { Props } from 'Plans/components/PlansTable'
import type { Action, Plan } from 'Types'

const mockedFetch = jest.fn()
mockedFetch.mockResolvedValue({ status: 200 })
global.fetch = mockedFetch

const consoleSpy = jest.fn()
console.error = consoleSpy

const actions: Action[] = [
  { title: 'Copy', path: '/copy', method: 'POST' },
  { title: 'Publish', path: '/publish', method: 'POST' },
  { title: 'Hide', path: '/hide', method: 'POST' },
  { title: 'Delete', path: '/delete', method: 'POST' }
]

const plans: Plan[] = [{ id: 0, name: 'Basic Plan', actions, contracts: 0, state: 'state', editPath: '/edit', contractsPath: '/apps' }]
const defaultProps: Props = {
  columns: [
    { attribute: 'name', title: 'Name' },
    { attribute: 'contracts_count', title: 'Contracts' },
    { attribute: 'state', title: 'State' }
  ],
  plans,
  count: plans.length
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<PlansTable {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.clearAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
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

  expect(mockedFetch).toHaveBeenCalledWith('/copy', expect.objectContaining({ method: 'POST' }))
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

  expect(mockedFetch).toHaveBeenCalledWith('/publish', expect.objectContaining({ method: 'POST' }))
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

  expect(mockedFetch).toHaveBeenCalledWith('/hide', expect.objectContaining({ method: 'POST' }))
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

  expect(mockedFetch).toHaveBeenCalledWith('/delete', expect.objectContaining({ method: 'DELETE' }))
})

it('should log an error if an action is unknown', () => {
  const action = { title: 'Unknown Action', path: '/actions/A', method: 'POST' } as const

  const wrapper = mountWrapper({ plans: [{ ...plans[0], id: 0, name: 'Basic Plan', actions: [action] }] })

  wrapper.find('.pf-c-dropdown__toggle').simulate('click')
  wrapper.find('button')
    .findWhere(b => b.text() === action.title)
    .find('button')
    .simulate('click')

  expect(consoleSpy).toHaveBeenLastCalledWith(`Unknown action: ${action.title}`)
})
