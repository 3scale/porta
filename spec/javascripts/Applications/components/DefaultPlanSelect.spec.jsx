// @flow

import React from 'react'

import { DefaultPlanSelect } from 'Applications'
import { mount } from 'enzyme'

const props = {
  currentService: { id: 0, name: 'Le Service' },
  currentPlan: undefined,
  plans: []
}

it('should render', () => {
  const wrapper = mount(<DefaultPlanSelect {...props} />)
  expect(wrapper.exists()).toBe(true)
})
