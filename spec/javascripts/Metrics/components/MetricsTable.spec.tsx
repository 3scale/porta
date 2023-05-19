import { mount } from 'enzyme'
import CheckIcon from '@patternfly/react-icons/dist/js/icons/check-icon'

import { MetricsTable } from 'Metrics/components/MetricsTable'

import type { Props } from 'Metrics/components/MetricsTable'

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

const defaultProps: Props = {
  activeTabKey: 'methods',
  mappingRulesPath: '',
  addMappingRulePath: '',
  metrics,
  metricsCount,
  createButton: <button type="button">Add a metric</button>
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<MetricsTable {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

it('should have a paginated table', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists('.pf-c-pagination')).toEqual(true)
})

describe('for metrics without mapping rule', () => {
  const metric = { ...metrics[0], mapped: false } as const

  it('should render a link to the add mapping rule page', () => {
    const addMappingRulePath = '/mapping_rules/new'
    const wrapper = mountWrapper({ metrics: [metric], addMappingRulePath })

    const mapped = wrapper.find('tr').find('td[data-label="Mapped"]')
    expect(mapped.containsMatchingElement(
      <a href={`${addMappingRulePath}?metric_id=${metric.id}`}>
        Add a mapping rule
      </a>
    )).toEqual(true)
  })
})

describe('for metrics with a mapping rule', () => {
  const metric = { ...metrics[0], mapped: true } as const

  it('should render a checkmark that link to the mapping rules page', () => {
    const mappingRulesPath = '/mapping_rules/'
    const wrapper = mountWrapper({ metrics: [metric], mappingRulesPath })

    const mapped = wrapper.find('tr').find('td[data-label="Mapped"]')
    expect(mapped.containsMatchingElement(
      <a href={mappingRulesPath}>
        <CheckIcon />
      </a>
    )).toEqual(true)
  })
})
