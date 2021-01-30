// @flow

import React from 'react'

import { DefaultPlanSelect } from 'Applications'
import { mount } from 'enzyme'

const props = {
  plan: undefined,
  plans: [],
  onSelectPlan: jest.fn(),
  isDisabled: false
}

it('should render', () => {
  const wrapper = mount(<DefaultPlanSelect {...props} />)
  expect(wrapper.exists()).toBe(true)
})
