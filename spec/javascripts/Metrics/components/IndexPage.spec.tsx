import { mount } from 'enzyme'

import { IndexPage } from 'Metrics/components/IndexPage'
import * as navigation from 'utilities/navigation'

import type { Props } from 'Metrics/components/IndexPage'

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

const defaultProps: Props = {
  metrics,
  metricsCount: metrics.length * 2,
  infoCard: <div>info</div>,
  addMappingRulePath: '',
  mappingRulesPath: '',
  createMetricPath
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<IndexPage {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

it('should be in Methods tab by default', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('.pf-c-tabs__item.pf-m-current').text()).toBe('Methods')
})

it('should have a table', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('MetricsTable tbody tr')).toHaveLength(metrics.length)
})

describe('when in Methods tab', () => {
  beforeEach(() => {
    jest.spyOn(URLSearchParams.prototype, 'get').mockReturnValueOnce('methods')
  })

  it('should change to tab Metrics', () => {
    const wrapper = mountWrapper()
    wrapper.find('.pf-c-tabs__item:not(.pf-m-current) button').simulate('click')
    expect(navigation.replace).toHaveBeenCalledTimes(1)
    expect(navigation.replace).toHaveBeenCalledWith(expect.stringContaining('tab=metrics'))
  })

  it('should have a button to create new methods', () => {
    const wrapper = mountWrapper()
    const button = wrapper.find(`.pf-c-button[href="${createMetricPath}"]`)
    expect(button.text()).toBe('Add a method')
  })
})

describe('when in Metrics tab', () => {
  beforeEach(() => {
    jest.spyOn(URLSearchParams.prototype, 'get').mockReturnValueOnce('metrics')
  })

  it('should change to tab Methods', () => {
    const wrapper = mountWrapper()
    wrapper.find('.pf-c-tabs__item:not(.pf-m-current) button').simulate('click')
    expect(navigation.replace).toHaveBeenCalledTimes(1)
    expect(navigation.replace).toHaveBeenCalledWith(expect.stringContaining('tab=methods'))
  })

  it('should have a button to create new methods', () => {
    const wrapper = mountWrapper()
    const button = wrapper.find(`.pf-c-button[href="${createMetricPath}"]`)
    expect(button.text()).toBe('Add a metric')
  })
})
