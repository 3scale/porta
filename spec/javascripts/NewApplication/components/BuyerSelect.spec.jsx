// @flow

import React from 'react'

import { BuyerSelect } from 'NewApplication'
import { mount } from 'enzyme'

const buyer = {
  id: '0',
  name: 'The Buyer',
  description: 'Admin: The Admin',
  contractedProducts: [],
  createApplicationPath: '',
  createdAt: ''
}
const buyers = [buyer]
const props = {
  buyer,
  mostRecentlyCreatedBuyers: buyers,
  buyersCount: buyers.length,
  onSelectBuyer: jest.fn(),
  buyersPath: '/buyers',
  isDisabled: false
}

it('should render', () => {
  const wrapper = mount(<BuyerSelect {...props} />)
  expect(wrapper.exists()).toBe(true)
})
