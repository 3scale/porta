// @flow

import React from 'react'
import { mount } from 'enzyme'

// $FlowIgnore[missing-export] export is there, name_mapper is the problem
import { ApplicationPlansTable } from 'Plans'

const plans = []
const defaultProps = {
  plans,
  count: plans.length,
  searchHref: '/plans'
}

const mountWrapper = (props) => mount(<ApplicationPlansTable {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should render a table with Name, Applications and State', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('th')).toMatchSnapshot()
})
