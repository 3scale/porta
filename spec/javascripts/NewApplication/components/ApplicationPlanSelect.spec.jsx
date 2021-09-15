// @flow

import React from 'react'

import { ApplicationPlanSelect } from 'NewApplication'
import { mount } from 'enzyme'

const product = { id: '0', name: 'API Product', description: 'api-product', updatedAt: '1 Jan 2021', appPlans: [{ id: 0, name: 'The Plan' }], servicePlans: [] }
const props = {
  product,
  appPlan: { id: 0, name: 'The Plan' },
  setAppPlan: jest.fn(),
  createApplicationPlanPath: '/plans',
  onSelect: jest.fn()
}

it('should render', () => {
  const wrapper = mount(<ApplicationPlanSelect {...props} />)
  expect(wrapper.exists()).toBe(true)
})
