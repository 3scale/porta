// @flow

import React from 'react'

import { DefaultPlanSelect } from 'Plans'
import { mount } from 'enzyme'

const onSelectPlan = jest.fn()
const plans = [{ id: 0, name: 'Plan 0' }, { id: 1, name: 'Plan 1' }]

const props = {
  plan: plans[0],
  plans,
  onSelectPlan,
  isLoading: undefined
}

beforeEach(() => {
  jest.resetAllMocks()
})

it('should render', () => {
  const wrapper = mount(<DefaultPlanSelect {...props} />)
  expect(wrapper.exists()).toBe(true)
})

it.todo('should be able to select an item')
it.todo('should never set plan as null')
it.todo('should show a spinner when loading')
