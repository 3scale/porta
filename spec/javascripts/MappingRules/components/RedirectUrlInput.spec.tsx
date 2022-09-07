import React from 'react';
import { mount } from 'enzyme'

import { RedirectUrlInput } from 'MappingRules'

const defaultProps = {
  redirectUrl: '',
  setRedirectUrl: () => {}
} as const

const mountWrapper = (props: undefined) => mount(<RedirectUrlInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
