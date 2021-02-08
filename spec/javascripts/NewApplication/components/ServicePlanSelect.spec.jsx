// @flow

import React from 'react'

import { ServicePlanSelect } from 'NewApplication'
import { mount } from 'enzyme'

const props = {
  servicePlan: { id: 0, name: 'The Plan' },
  setServicePlan: jest.fn(),
  servicePlans: [{ id: 0, name: 'The Plan' }],
  onSelect: jest.fn()
}

it('should render', () => {
  const wrapper = mount(<ServicePlanSelect {...props} />)
  expect(wrapper.exists()).toBe(true)
})
