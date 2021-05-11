// @flow

import React from 'react'
import { mount } from 'enzyme'

import { RedirectUrlInput } from 'MappingRules'

const defaultProps = {
  redirectUrl: '',
  setRedirectUrl: () => {}
}

const mountWrapper = (props) => mount(<RedirectUrlInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
