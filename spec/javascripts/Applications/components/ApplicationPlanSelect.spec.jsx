// @flow

import React from 'react'

import { ApplicationPlanSelect } from 'Applications'
import { mount } from 'enzyme'

const props = {
  appPlan: { id: 0, name: 'The Plan' },
  setAppPlan: jest.fn(),
  appPlans: [{ id: 0, name: 'The Plan' }],
  createApplicationPlanPath: '/plans'
}

it('should render', () => {
  const wrapper = mount(<ApplicationPlanSelect {...props} />)
  expect(wrapper.exists()).toBe(true)
})
