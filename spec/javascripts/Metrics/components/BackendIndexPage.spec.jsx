// @flow

import React from 'react'
import { mount } from 'enzyme'

import { BackendIndexPage } from 'Metrics'

const defaultProps = {
  applicationPlansPath: '/plans',
  createMetricPath: '/methods/new',
  mappingRulesPath: '/mapping-rules',
  metrics: [],
  metricsCount: 0
}

const mountWrapper = (props) => mount(<BackendIndexPage {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
