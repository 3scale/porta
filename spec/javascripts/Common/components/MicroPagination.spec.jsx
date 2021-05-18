// @flow

import React from 'react'
import { mount } from 'enzyme'

import { MicroPagination } from 'Common'

const setPage = jest.fn()
const lastPage = 5

const defaultProps = {
  page: 1,
  lastPage,
  setPage
}

const mountWrapper = (props) => mount(<MicroPagination {...{ ...defaultProps, ...props }} />)
const previousPageButton = (wrapper) => wrapper.find('Button').first()
const nextPageButton = (wrapper) => wrapper.find('Button').last()

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

describe('when on the first page', () => {
  const props = { ...defaultProps, page: 1 }

  it('should not be able to go to the previous page', () => {
    const wrapper = mountWrapper(props)
    const button = previousPageButton(wrapper)
    expect(button.props().isDisabled).toBe(true)

    button.simulate('click')
    expect(setPage).not.toHaveBeenCalled()
  })

  it('should be able to go to the next page', () => {
    const wrapper = mountWrapper(props)
    const button = nextPageButton(wrapper)
    expect(button.props().isDisabled).toBe(false)

    button.simulate('click')
    expect(setPage).toHaveBeenCalledWith(2)
  })
})

describe('when on the last page', () => {
  const props = { ...defaultProps, page: lastPage }

  it('should be able to go to the previous page', () => {
    const wrapper = mountWrapper(props)
    const button = previousPageButton(wrapper)
    expect(button.props().isDisabled).toBe(false)

    button.simulate('click')
    expect(setPage).toHaveBeenCalledWith(lastPage - 1)
  })

  it('should not be able to go to the next page', () => {
    const wrapper = mountWrapper(props)
    const button = nextPageButton(wrapper)
    expect(button.props().isDisabled).toBe(true)

    button.simulate('click')
    expect(setPage).not.toHaveBeenCalled()
  })
})
