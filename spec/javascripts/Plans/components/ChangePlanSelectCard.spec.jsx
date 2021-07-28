// @flow

import React from 'react'
import { mount } from 'enzyme'

import { ChangePlanSelectCard } from 'Plans'

const defaultProps = {
  // props here
}

const mountWrapper = (props) => mount(<ChangePlanSelectCard {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

describe('when there is NO plan previewsly selected', () => {
  it.todo('should have a disabled button')
  it.todo('should be able to select a plan')
})

describe('when there is a plan previewsly selected', () => {
  it.todo('should have a disabled button')
  it.todo('should be able to select a different plan')
})
