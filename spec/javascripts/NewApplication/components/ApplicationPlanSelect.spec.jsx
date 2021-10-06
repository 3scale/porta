// @flow

import React from 'react'

import { ApplicationPlanSelect } from 'NewApplication'
import { mount } from 'enzyme'

const product = { id: '0', name: 'API Product', description: 'api-product', updatedAt: '1 Jan 2021', appPlans: [{ id: 0, name: 'The Plan' }], servicePlans: [], buyerCanSelectPlan: true }
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

it('should be disabled when application plans is empty', () => {
  const newProps = {
    ...props,
    product: {
      ...product,
      appPlans: []
    }
  }
  const wrapper = mount(<ApplicationPlanSelect {...newProps} />)
  expect(wrapper.find('.pf-c-select__toggle-typeahead').props().disabled).toBe(true)
  expect(wrapper.find('.pf-c-select__toggle-button').props().disabled).toBe(true)
})

it('should not be disabled when application plans is not empty', () => {
  const wrapper = mount(<ApplicationPlanSelect {...props} />)
  expect(wrapper.find('.pf-c-select__toggle-typeahead').props().disabled).toBe(false)
  expect(wrapper.find('.pf-c-select__toggle-button').props().disabled).toBe(false)
})
