// @flow

import React from 'react'
import { act } from 'react-dom/test-utils'
import { DefaultPlanSelectCard } from 'Plans/components/DefaultPlanSelectCard'
import { mount } from 'enzyme'

import * as alert from 'utilities/alert'
const noticeSpy = jest.spyOn(alert, 'notice')
const errorSpy = jest.spyOn(alert, 'error')

jest.mock('utilities/ajax')
import * as AJAX from 'utilities/ajax'
const ajax = (AJAX.ajax: JestMockFn<empty, any>)

const plan = { id: 1, name: 'My Plan' }
const defaultProps = {
  plans: [plan],
  initialDefaultPlan: null,
  path: '/foo/bar'
}

const mountWrapper = (props) => mount(<DefaultPlanSelectCard {...{ ...defaultProps, ...props }} />)

const openSelect = (wrapper) => wrapper.find('.pf-c-select__toggle-button').simulate('click')
const selectPlan = (wrapper, plan) => act(async () => wrapper.find('DefaultPlanSelect').invoke('onSelectPlan')(plan))

it('should render', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should show a success message if request goes well', async () => {
  ajax.mockResolvedValue({ ok: true })
  const wrapper = mountWrapper()

  await selectPlan(wrapper, plan)

  expect(noticeSpy).toHaveBeenCalledWith('Default plan was updated')
})

it('should show an error message when selected plan does not exist', async () => {
  ajax.mockResolvedValueOnce({ status: 404 })
  const wrapper = mountWrapper()

  await selectPlan(wrapper, plan)

  expect(errorSpy).toHaveBeenCalledWith("The selected plan doesn't exist.")
})

it('should show an error message when server returns an error', async () => {
  ajax.mockResolvedValue({ status: 403 })
  const wrapper = mountWrapper()

  await selectPlan(wrapper, plan)

  expect(errorSpy).toHaveBeenCalledWith('Plan could not be updated')
})

it('should show an error message when connection fails', async () => {
  // $FlowExpectedError[cannot-write] suppress error logs during test
  console.error = jest.fn()

  ajax.mockRejectedValue()
  const wrapper = mountWrapper()

  await selectPlan(wrapper, plan)

  expect(errorSpy).toHaveBeenCalledWith('An error ocurred. Please try again later.')
})

it('should not add a "no default plan" option by default', () => {
  const wrapper = mountWrapper()
  openSelect(wrapper)
  expect(wrapper.find('.pf-c-select SelectOption').findWhere(n => n.text() === '(No default plan)').exists()).toBe(false)
})

describe('when a plan is default', () => {
  const props = { ...defaultProps, initialDefaultPlan: plan }

  it('should add a "no default plan" option to the select', () => {
    const wrapper = mountWrapper(props)
    openSelect(wrapper)
    expect(wrapper.find('.pf-c-select SelectOption').first().text()).toEqual('(No default plan)')
  })
})
