// @flow

import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import { ApplicationForm } from 'Applications/ApplicationForm'

Enzyme.configure({ adapter: new Adapter() })

let wrapper

function getWrapper () {
  const props = { applicationPlans: [], servicePlansAllowed: true }

  wrapper = mount(<ApplicationForm {...props} />)
}

beforeEach(() => {
  getWrapper()
})

afterEach(() => {
  wrapper.unmount()
})

it('should render itself', () => {
  expect(wrapper.find(ApplicationForm).exists()).toBe(true)
})

describe('when service plans are allowed', () => {
  beforeEach(() => {
    wrapper.setProps({ servicePlansAllowed: true })
  })

  it('should render an input for the selected plan', () => {
    expect(wrapper.find('input#cinstance_service_plan_id').exists()).toBe(true)
  })
})

describe('when service plans are not allowed', () => {
  beforeEach(() => {
    wrapper.setProps({ servicePlansAllowed: false })
  })

  it('should not render an input for the selected plan', () => {
    expect(wrapper.find('input#cinstance_service_plan_id').exists()).toBe(false)
  })
})
