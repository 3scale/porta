import React from 'react'
import { mount } from 'enzyme'

import { BackendAPIIndexPage, Props } from 'Metrics/components/BackendAPIIndexPage'

const defaultProps: Props = {
  addMappingRulePath: '/mapping-rule/new',
  createMetricPath: '/metrics/new',
  mappingRulesPath: '/mapping-rules',
  metrics: [],
  metricsCount: 0
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<BackendAPIIndexPage {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
