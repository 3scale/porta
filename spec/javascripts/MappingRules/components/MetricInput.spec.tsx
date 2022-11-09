import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { MetricInput } from 'MappingRules/components/MetricInput'

import type { FormEvent } from 'react'
import type { RadioProps } from '@patternfly/react-core'
import type { Props } from 'MappingRules/components/MetricInput'

const defaultProps = {
  metric: { id: 0, name: 'Metric 0', systemName: '', updatedAt: '' },
  setMetric: jest.fn(),
  topLevelMetrics: [{ id: 0, name: 'Metric 0', systemName: '', updatedAt: '' }],
  methods: [{ id: 1, name: 'Method 1', systemName: '', updatedAt: '' }]
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<MetricInput {...{ ...defaultProps, ...props }} />)

describe('when no metric is selected', () => {
  const props = { metric: null }

  it('should render itself', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.exists()).toEqual(true)
  })
})

describe('when a metric selected', () => {
  it('should render itself', () => {
    const wrapper = mountWrapper()
    expect(wrapper.exists()).toEqual(true)
  })

  it('should show metrics or methods select depending on the radio checked', () => {
    const wrapper = mountWrapper()

    act(() => {
      const props = wrapper.find('Radio#proxy_rule_metric_id_radio_method').props() as RadioProps
      props.onChange!(true, {} as FormEvent<HTMLInputElement>)
    })
    wrapper.update()
    expect(wrapper.exists('#wrapper_method .pf-c-select')).toEqual(true)
    expect(wrapper.exists('#wrapper_metric .pf-c-select')).toEqual(false)

    act(() => {
      const props = wrapper.find('Radio#proxy_rule_metric_id_radio_metric').props() as RadioProps
      props.onChange!(true, {} as FormEvent<HTMLInputElement>)
    })
    wrapper.update()
    expect(wrapper.exists('#wrapper_method .pf-c-select')).toEqual(false)
    expect(wrapper.exists('#wrapper_metric .pf-c-select')).toEqual(true)
  })
})
