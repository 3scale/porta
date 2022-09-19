import React from 'react'
import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { MetricInput } from 'MappingRules'

const defaultProps = {
  metric: { id: 0, name: 'Metric 0', systemName: '', updatedAt: '' },
  setMetric: () => {},
  topLevelMetrics: [{ id: 0, name: 'Metric 0', systemName: '', updatedAt: '' }],
  methods: [{ id: 1, name: 'Method 1', systemName: '', updatedAt: '' }]
} as const

const mountWrapper = (props: Partial<Props> = {}) => mount(<MetricInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should show metrics or methods select depending on the radio checked', () => {
  const wrapper = mountWrapper()

  act(() => wrapper.find('Radio#proxy_rule_metric_id_radio_method').props().onChange())
  wrapper.update()
  expect(wrapper.find('#wrapper_method .pf-c-select').exists()).toBe(true)
  expect(wrapper.find('#wrapper_metric .pf-c-select').exists()).toBe(false)

  act(() => wrapper.find('Radio#proxy_rule_metric_id_radio_metric').props().onChange())
  wrapper.update()
  expect(wrapper.find('#wrapper_method .pf-c-select').exists()).toBe(false)
  expect(wrapper.find('#wrapper_metric .pf-c-select').exists()).toBe(true)
})
