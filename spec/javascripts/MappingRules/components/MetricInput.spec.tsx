import { FormEvent } from 'react'
import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'
import { RadioProps } from '@patternfly/react-core'

import { MetricInput, Props } from 'MappingRules/components/MetricInput'

const defaultProps = {
  metric: { id: 0, name: 'Metric 0', systemName: '', updatedAt: '' },
  setMetric: jest.fn(),
  topLevelMetrics: [{ id: 0, name: 'Metric 0', systemName: '', updatedAt: '' }],
  methods: [{ id: 1, name: 'Method 1', systemName: '', updatedAt: '' }]
}

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

  act(() => {
    const props = wrapper.find('Radio#proxy_rule_metric_id_radio_method').props() as RadioProps
    props.onChange!(true, {} as FormEvent<HTMLInputElement>)
  })
  wrapper.update()
  expect(wrapper.find('#wrapper_method .pf-c-select').exists()).toBe(true)
  expect(wrapper.find('#wrapper_metric .pf-c-select').exists()).toBe(false)

  act(() => {
    const props = wrapper.find('Radio#proxy_rule_metric_id_radio_metric').props() as RadioProps
    props.onChange!(true, {} as FormEvent<HTMLInputElement>)
  })
  wrapper.update()
  expect(wrapper.find('#wrapper_method .pf-c-select').exists()).toBe(false)
  expect(wrapper.find('#wrapper_metric .pf-c-select').exists()).toBe(true)
})
