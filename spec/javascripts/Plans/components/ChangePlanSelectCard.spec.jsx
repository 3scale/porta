// @flow

import React from 'react'
import { mount } from 'enzyme'

import { ChangePlanSelectCard } from 'Plans'

import type { SelectOptionObject } from 'utilities'

const plan = { id: 0, name: 'I am a plan' }
const defaultProps = {
  applicationPlans: [plan, { id: 1, name: 'I am another plan' }],
  path: '/applications/123/change_plan'
}

const mountWrapper = (props) => mount(<ChangePlanSelectCard {...{ ...defaultProps, ...props }} />)
const openSelect = (wrapper) => wrapper.find('Select button.pf-c-select__toggle-button').simulate('click')

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should be able to select a plan', () => {
  const wrapper = mountWrapper()
  openSelect(wrapper)
  wrapper.find('SelectOption button').first().simulate('click')

  const selected: SelectOptionObject = wrapper.find('Select#cinstance_plan_id').prop('selections')
  expect(selected.name).toBe(plan.name)
})

it('should have a disabled button', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('button[type="submit"]').prop('disabled')).toBe(true)
})

it('should enable the button when a plan is selected', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('button[type="submit"]').prop('disabled')).toBe(true)

  openSelect(wrapper)
  wrapper.find('SelectOption button').first().simulate('click')

  expect(wrapper.find('button[type="submit"]').prop('disabled')).toBe(false)
})

it('should disable the plan already selected', () => {
  const wrapper = mountWrapper()
  const option = () => wrapper.find('SelectOption button').findWhere(n => n.text() === 'I am a plan').first()

  openSelect(wrapper)
  option().simulate('click')
  expect(wrapper.find('Select#cinstance_plan_id').prop('selections').name).toBe(plan.name)

  openSelect(wrapper)
  expect(option().prop('className')).toMatch('pf-m-disabled')
})

// FIXME: input not receiving change event
it.skip('should be able to filter by name', () => {
  const wrapper = mountWrapper()
  openSelect(wrapper)
  expect(wrapper.find('SelectOption')).toHaveLength(2)

  wrapper.find('input[type="text"]').simulate('change', { target: { value: 'another' } })
  wrapper.update()
  expect(wrapper.find('SelectOption')).toHaveLength(1)
})
