// @flow

import React from 'react'
import { mount } from 'enzyme'

import { EmailConfigurationsTable } from 'EmailConfigurations/components/EmailConfigurationsTable'

const defaultProps = {
  // props here
}

const mountWrapper = (props) => mount(<EmailConfigurationsTable {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
