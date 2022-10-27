import { mount } from 'enzyme'

import { NewMappingRule, Props } from 'MappingRules/components/NewMappingRule'

const defaultProps: Props = {
  url: 'mapping_rules/new',
  topLevelMetrics: [],
  methods: [],
  httpMethods: []
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<NewMappingRule {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
