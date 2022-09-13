import React from 'react'
import { mount } from 'enzyme'

import { NewMappingRule } from 'MappingRules'

const defaultProps = {
  url: 'mapping_rules/new',
  topLevelMetrics: [],
  methods: [],
  httpMethods: []
} as const

const mountWrapper = (props: undefined) => mount(<NewMappingRule {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
