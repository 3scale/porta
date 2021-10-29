// @flow

import React from 'react'

import { BuyerSelect } from 'NewApplication'
import { mount } from 'enzyme'

const buyer = {
  id: 0,
  name: 'The Buyer',
  admin: 'admin',
  contractedProducts: [],
  createApplicationPath: '',
  createdAt: '',
  multipleAppsAllowed: false
}
const props = {
  buyer,
  buyers: [buyer],
  onSelectBuyer: jest.fn(),
  isDisabled: false
}

it('should render', () => {
  const wrapper = mount(<BuyerSelect {...props} />)
  expect(wrapper.exists()).toBe(true)
})
