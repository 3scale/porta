import React from 'react'
import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { SystemNameInput } from 'BackendApis'

const setSystemName = jest.fn()

const defaultProps = {
  systemName: '',
  setSystemName
} as const

const mountWrapper = (props: undefined) => mount(<SystemNameInput {...{ ...defaultProps, ...props }} />)

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

  act(() => wrapper.find(SystemNameInput).props().setSystemName(value))

  wrapper.update()
  expect(setSystemName).toHaveBeenCalledWith(value)
})
