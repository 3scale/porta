// @flow

import React from 'react'
import { mount } from 'enzyme'

import { NewPage } from 'EmailConfigurations/components/NewPage'

const defaultProps = {
  // props here
}

const mountWrapper = (props) => mount(<NewPage {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
