import { mount } from 'enzyme'

import { CheckIcon } from '@patternfly/react-icons'
import { MetricsTable, Props } from 'Metrics/components/MetricsTable'
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

const defaultProps: Props = {
  activeTabKey: 'methods',
  mappingRulesPath: '',
  addMappingRulePath: '',
  metrics,
  metricsCount,
  createButton: <button>Add a metric</button>
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<MetricsTable {...{ ...defaultProps, ...props }} />)

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
    )).toBe(true)
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
    )).toBe(true)
  })
})
