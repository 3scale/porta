// @flow

import React from 'react'
import { mount } from 'enzyme'

import { PlansTable } from 'Plans/components/PlansTable'

const plans = []
const defaultProps = {
  columns: [],
  onAction: () => {},
  plans,
  count: plans.length,
  searchHref: '/plans'
}

const mountWrapper = (props) => mount(<PlansTable {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it.todo('should render a table with the given columns')
// it('should render a table with Name, Applications and State', () => {
//   const wrapper = mountWrapper()
//   expect(wrapper.find('th')).toMatchSnapshot()
// })
