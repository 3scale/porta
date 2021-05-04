// @flow

import React from 'react'
import { mount } from 'enzyme'

import { IndexPage } from 'Metrics'

const defaultProps = {
  infoCard: <div>info</div>
}

const mountWrapper = (props) => mount(<IndexPage {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
