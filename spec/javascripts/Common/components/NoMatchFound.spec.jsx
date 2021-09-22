// @flow

import React from 'react'
import { mount } from 'enzyme'

import { NoMatchFound } from 'Common'

const onClearFiltersClick = jest.fn()
const defaultProps = {}

const mountWrapper = (props) => mount(<NoMatchFound {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should not render a button', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('Button').exists()).toBe(false)
})

describe('with an All Filter Clear button', () => {
  const props = { onClearFiltersClick }

  it('should render a button', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.find('Button').text()).toEqual('Clear all filters')
  })

  it('should invoke the callback', () => {
    const wrapper = mountWrapper(props)
    wrapper.find('Button').props().onClick()
    expect(onClearFiltersClick).toHaveBeenCalledTimes(1)
  })
})
