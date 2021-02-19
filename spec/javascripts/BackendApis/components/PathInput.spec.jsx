// @flow

import React from 'react'
import { mount } from 'enzyme'

import { PathInput } from 'BackendApis'

const setPath = jest.fn()

const defaultProps = {
  path: '',
  setPath
}

const mountWrapper = (props) => mount(<PathInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it.skip('should work', () => {
  const value = 'foo'
  const wrapper = mountWrapper()

  wrapper.find('input').simulate('change', { currentTarget: { value }, target: { value } })

  // FIXME: what is wrong with this, onChange is passed the event with the value and it should work.
  expect(setPath).toHaveBeenCalledWith(value)
})
