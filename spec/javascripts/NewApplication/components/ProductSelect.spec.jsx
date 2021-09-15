// @flow

import React from 'react'

import { ProductSelect } from 'NewApplication'
import { mount } from 'enzyme'

const product = {
  id: '0',
  name: 'The Product',
  description: 'the_product',
  updatedAt: '',
  appPlans: [],
  servicePlans: [],
  defaultServicePlan: undefined
}
const products = [product]
const props = {
  product,
  mostRecentlyUpdatedProducts: products,
  productsCount: products.length,
  onSelectProduct: jest.fn(),
  productsPath: '/products',
  isDisabled: undefined
}

it('should render', () => {
  const wrapper = mount(<ProductSelect {...props} />)
  expect(wrapper.exists()).toBe(true)
})
