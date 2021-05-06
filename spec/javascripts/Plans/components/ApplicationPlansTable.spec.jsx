// @flow

import React from 'react'
import { mount } from 'enzyme'

import { ApplicationPlansTable } from 'Plans'

const plans = []
const defaultProps = {
  onAction: () => {},
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
