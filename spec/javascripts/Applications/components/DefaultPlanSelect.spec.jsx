// @flow

import React from 'react'

import { DefaultPlanSelect } from 'Plans'
import { mount } from 'enzyme'

const props = {
  plan: { id: 0, name: 'Plan 0' },
  plans: [{ id: 0, name: 'Plan 0' }],
  onSelectPlan: jest.fn(),
  isDisabled: false
}

it('should render', () => {
  const wrapper = mount(<DefaultPlanSelect {...props} />)
  expect(wrapper.exists()).toBe(true)
})
