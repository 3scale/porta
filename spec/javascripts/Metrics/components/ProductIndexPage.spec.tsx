import { mount } from 'enzyme'

import { ProductIndexPage } from 'Metrics/components/ProductIndexPage'

import type { Props } from 'Metrics/components/ProductIndexPage'

const defaultProps: Props = {
  applicationPlansPath: '/plans',
  addMappingRulePath: '/mapping-rule/new',
  createMetricPath: '/metrics/new',
  mappingRulesPath: '/mapping-rules',
  metrics: [],
  metricsCount: 0
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ProductIndexPage {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})
