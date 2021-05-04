// @flow

import React from 'react'
import { mount } from 'enzyme'

import { ProductIndexPage } from 'Metrics'

const defaultProps = {
  mappingRulesPath: '/mapping-rules',
  applicationPlansPath: '/plans'
}

const mountWrapper = (props) => mount(<ProductIndexPage {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
