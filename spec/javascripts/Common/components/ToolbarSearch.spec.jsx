// @flow

import React from 'react'
import { mount } from 'enzyme'

import { ToolbarSearch } from 'Common'

const defaultProps = {
  placeholder: ''
}

const mountWrapper = (props) => mount(<ToolbarSearch {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should have a placeholder', () => {
  const placeholder = 'Find something'
  const wrapper = mountWrapper({ placeholder })
  expect(wrapper.find(`input[placeholder="${placeholder}"]`).exists()).toBe(true)
})
