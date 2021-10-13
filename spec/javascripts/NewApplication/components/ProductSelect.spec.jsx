// @flow

import React from 'react'

import { ProductSelect } from 'NewApplication'
import { mount } from 'enzyme'

const product = {
  id: 0,
  name: 'The Product',
  systemName: 'the_product',
  updatedAt: '',
  appPlans: [],
  servicePlans: [],
  defaultServicePlan: null,
  defaultAppPlan: null,
  buyerCanSelectPlan: false
}
const props = {
  product,
  products: [product],
  onSelectProduct: jest.fn(),
  isDisabled: false
}

it('should render', () => {
  const wrapper = mount(<ProductSelect {...props} />)
  expect(wrapper.exists()).toBe(true)
})
