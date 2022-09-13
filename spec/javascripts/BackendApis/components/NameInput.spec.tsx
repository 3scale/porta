import React from 'react'
import { act } from 'react-dom/test-utils'
import { mount, ReactWrapper } from 'enzyme'

import { NameInput } from 'BackendApis'

const setName = jest.fn()

const defaultProps = {
  name: '',
  setName
}
declare global {
  interface Window {
    api?: any;
  }
}
const mountWrapper = (props = {}) => mount(<NameInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should work', () => {
  const value = 'foo'
  const wrapper = mountWrapper()

  act(() => {
    const input: ReactWrapper<{ setName: Function }> = wrapper.find(NameInput)
    input.props().setName(value)
  })

  wrapper.update()

  expect(setName).toHaveBeenCalledWith(value)
})
