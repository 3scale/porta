// @flow

import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import { ApplicationForm } from 'Applications/ApplicationForm'

Enzyme.configure({ adapter: new Adapter() })

let wrapper

function getWrapper () {
  const props = { applicationPlans: [] }

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
