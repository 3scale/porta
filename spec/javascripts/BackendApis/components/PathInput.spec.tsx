import React from 'react'
import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { PathInput } from 'BackendApis'

const setPath = jest.fn()

const defaultProps = {
  path: '',
  setPath
} as const

const mountWrapper = (props: undefined) => mount(<PathInput {...{ ...defaultProps, ...props }} />)

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

  act(() => wrapper.find(PathInput).props().setPath(value))

  wrapper.update()
  expect(setPath).toHaveBeenCalledWith(value)
})
