// @flow

import React from 'react'
import { mount } from 'enzyme'

import { DefaultPlanSelectCard } from 'Plans'

import type { SelectOptionObject } from 'utilities'

import { openSelect } from 'utilities/test-utils'

const plan = { id: 1, name: 'My Plan' }
const defaultProps = {
  product: { id: 0, name: 'My API', appPlans: [plan], systemName: 'my_api' },
  initialDefaultPlan: null,
  path: '/foo/bar'
}

// it should have a no_default_plan
// it should be able to filter by name 

const mountWrapper = (props) => mount(<DefaultPlanSelectCard {...{ ...defaultProps, ...props}}/>)

it('should render', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should have a helper text', () => {
  const wrapper = mountWrapper()
  
  const helperText = wrapper.find('.pf-c-helper-text')

  expect(helperText.exists()).toBe(true)
})

it('should have a no default plan inside plans', () => {
  const wrapper = mountWrapper()
  openSelect(wrapper)

  //Check what to do here
})

// TODO: Fix this test
it('should be able to select a plan', () => {
  const wrapper = mountWrapper()
  openSelect(wrapper)
  wrapper.find('SelectOption button').first().simulate('click')

  const selected: SelectOptionObject = wrapper.find('Select#id').prop('selections')
  expect(selected.name).toBe('(No default plan)')
})

it('should have a disabled button', () => {
  const wrapper = mountWrapper()
  wrapper.find('.pf-c-select__toggle-clear').simulate('click')

  expect(wrapper.find('button[type="submit"]').prop('disabled')).toBe(true)
})

it('should enable the button when a plan is selected', () => {
  const wrapper = mountWrapper()
  wrapper.find('.pf-c-select__toggle-clear').simulate('click')
  expect(wrapper.find('button[type="submit"]').prop('disabled')).toBe(true)

  openSelect(wrapper)
  wrapper.find('SelectOption button').first().simulate('click')

  expect(wrapper.find('button[type="submit"]').prop('disabled')).toBe(false)
})

it('should disable the plan already selected', () => {
  const wrapper = mountWrapper()
  const option = () => wrapper.find('SelectOption button').findWhere(n => n.text() === 'My Plan').first()

  openSelect(wrapper)
  option().simulate('click')
  expect(wrapper.find('Select#id').prop('selections').name).toBe(plan.name)

  openSelect(wrapper)
  expect(option().prop('className')).toMatch('pf-m-disabled')
})
