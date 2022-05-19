// @flow

import React from 'react'
import { act } from 'react-dom/test-utils'

import { DefaultPlanSelect } from 'Plans/components/DefaultPlanSelect'
import { mount } from 'enzyme'

const onSelectPlan = jest.fn()
const plans = [{ id: 0, name: 'Plan 0' }, { id: 1, name: 'Plan 1' }]
const currentPlan = plans[0]

const defaultProps = {
  plan: currentPlan,
  plans,
  onSelectPlan,
  isLoading: undefined
}

const mountWrapper = (props) => mount(<DefaultPlanSelect {...{ ...defaultProps, ...props }} />)
const selectPlan = (wrapper, plan) => act(async () => wrapper.find('Select').first().props().onSelect(plan))

beforeEach(() => {
  jest.resetAllMocks()
})

it('should render', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should be able to select an item', async () => {
  const newPlan = plans[0]
  const wrapper = mountWrapper()

  wrapper.find('.pf-c-select__toggle-button').simulate('click')
  expect(wrapper.find('ul SelectOption').length).toEqual(plans.length)

  await selectPlan(wrapper, newPlan)
  expect(onSelectPlan).toHaveBeenCalledWith(newPlan)
})

it('should never set plan as null', async () => {
  const wrapper = mountWrapper({ plan: plans[1] })

  await selectPlan(wrapper, null)
  expect(onSelectPlan).not.toHaveBeenCalled()
})

it('should show a spinner when loading', () => {
  const wrapper = mountWrapper({ isLoading: false })
  expect(wrapper.find('Spinner').exists()).toBe(false)

  wrapper.setProps({ isLoading: true })
  expect(wrapper.find('Spinner').exists()).toBe(true)
})
