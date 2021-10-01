// @flow

import React from 'react'
import { mount } from 'enzyme'

import { ToolbarSearch } from 'Common'

const mountWrapper = (props) => mount(<ToolbarSearch />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
