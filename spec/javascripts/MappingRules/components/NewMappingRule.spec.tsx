import { mount } from 'enzyme'

import { NewMappingRule } from 'MappingRules/components/NewMappingRule'

import type { Props } from 'MappingRules/components/NewMappingRule'

const defaultProps: Props = {
  url: 'mapping_rules/new',
  topLevelMetrics: [],
  methods: [],
  httpMethods: []
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<NewMappingRule {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})
