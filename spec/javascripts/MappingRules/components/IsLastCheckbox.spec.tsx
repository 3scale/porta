import React from 'react'
import { mount } from 'enzyme'

import { IsLastCheckbox } from 'MappingRules'

const defaultProps = {
  isLast: false,
  setIsLast: () => {}
} as const

const mountWrapper = (props: undefined) => mount(<IsLastCheckbox {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
