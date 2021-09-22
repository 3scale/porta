// @flow

import React from 'react'
import { mount } from 'enzyme'

import { IndexPage } from 'Metrics'

const metrics = new Array(5).fill({}).map((i, j) => ({
  id: j,
  name: `Metric no. ${j}`,
  systemName: `metric_no_${j}`,
  path: `/metrics/${j}`,
  unit: `unit_${j}`,
  description: `This is the metric number ${j}`,
  mapped: true,
  updatedAt: Date.now().toString()
}))

const createMetricPath = '/metrics/new'

const defaultProps = {
  metrics,
  metricsCount: metrics.length * 2,
  infoCard: <div>info</div>,
  createMetricPath
}

const mountWrapper = (props) => mount(<IndexPage {...{ ...defaultProps, ...props }} />)

const mockLocation = (href: string) => {
  delete window.location
  const location: Location = (new URL(href): any) // emulates Location object
  // $FlowIgnore[cannot-write]
  location.replace = jest.fn()
  window.location = location
}

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should be in Methods tab by default', () => {
  mockLocation('https://foo.bar')
  const wrapper = mountWrapper()
  expect(wrapper.find('.pf-c-tabs__item.pf-m-current').text()).toBe('Methods')
})

it('should have a table', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('MetricsTable tbody tr')).toHaveLength(metrics.length)
})

describe('when in Methods tab', () => {
  beforeEach(() => {
    mockLocation('https://foo.bar?tab=methods')
  })

  it('should change to tab Metrics', () => {
    const wrapper = mountWrapper()
    wrapper.find('.pf-c-tabs__item:not(.pf-m-current) button').simulate('click')
    expect(window.location.replace).toHaveBeenCalledTimes(1)
    expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('tab=metrics'))
  })

  it('should have a button to create new methods', () => {
    const wrapper = mountWrapper()
    const button = wrapper.find(`.pf-c-button[href="${createMetricPath}"]`)
    expect(button.text()).toBe('Add Method')
  })
})

describe('when in Metrics tab', () => {
  beforeEach(() => {
    mockLocation('https://foo.bar?tab=metrics')
  })

  it('should change to tab Methods', () => {
    const wrapper = mountWrapper()
    wrapper.find('.pf-c-tabs__item:not(.pf-m-current) button').simulate('click')
    expect(window.location.replace).toHaveBeenCalledTimes(1)
    expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('tab=methods'))
  })

  it('should have a button to create new methods', () => {
    const wrapper = mountWrapper()
    const button = wrapper.find(`.pf-c-button[href="${createMetricPath}"]`)
    expect(button.text()).toBe('Add Metric')
  })
})
