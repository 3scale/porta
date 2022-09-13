import React from 'react'
import { mount } from 'enzyme'

import { PositionInput } from 'MappingRules'

const defaultProps = {
  position: 0,
  setPosition: () => {}
} as const

const mountWrapper = (props: undefined) => mount(<PositionInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
