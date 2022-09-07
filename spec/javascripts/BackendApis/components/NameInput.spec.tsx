import React from 'react';
import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { NameInput } from 'BackendApis'

const setName = jest.fn()

const defaultProps = {
  name: '',
  setName
} as const

const mountWrapper = (props: undefined) => mount(<NameInput {...{ ...defaultProps, ...props }} />)

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

  act(() => wrapper.find(NameInput).props().setName(value))

  wrapper.update()
  expect(setName).toHaveBeenCalledWith(value)
})
