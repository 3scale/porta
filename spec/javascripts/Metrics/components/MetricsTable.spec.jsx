// @flow

import React from 'react'
import { mount } from 'enzyme'

import { MetricsTable } from 'Metrics'
import { mockLocation } from 'utilities/test-utils'

const metrics = new Array(6).fill({}).map((i, j) => ({
  id: j,
  name: `Metric no. ${j}`,
  systemName: `metric_no_${j}`,
  path: `/metrics/${j}`,
  unit: `unit_${j}`,
  description: `This is the metric number ${j}`,
  mapped: true,
  updatedAt: Date.now().toString()
}))
const metricsCount = metrics.length * 2

const defaultProps = {
  activeTabKey: 'methods',
  metrics,
  metricsCount,
  createButton: <button>Add metric</button>
}

const mountWrapper = (props) => mount(<MetricsTable {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should have a paginated table', () => {
  mockLocation(`href://foo.bar/metrics?per_page=2&page=2`)
  const wrapper = mountWrapper()
  const pagination = wrapper.find('.pf-c-pagination').first()

  expect(pagination.find('[aria-label="Current page"]').first().prop('value')).toBe(2)

  pagination.find('button[data-action="first"]').simulate('click')
  expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('page=1'))

  pagination.find('button[data-action="previous"]').simulate('click')
  expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('page=1'))

  pagination.find('button[data-action="next"]').simulate('click')
  expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('page=3'))

  pagination.find('button[data-action="last"]').simulate('click')
  expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('page=3'))

  expect(pagination.find('.pf-c-options-menu__toggle-text').text()).toMatch(`3 - 4 of ${metricsCount}`)
})
