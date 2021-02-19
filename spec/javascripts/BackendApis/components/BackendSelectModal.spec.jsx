// @flow

import React from 'react'
import { mount } from 'enzyme'

import { BackendSelectModal } from 'BackendApis'

const onClose = jest.fn()
const onSelectBackend = jest.fn()

const backend = { id: 0, name: 'My Backend', privateEndpoint: 'example.org' }
const defaultProps = {
  backend: null,
  backends: [backend],
  onClose,
  onSelectBackend,
  isOpen: true
}

const mountWrapper = (props) => mount(<BackendSelectModal {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should render Name, Private Base URL and Last updated', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('th')).toMatchSnapshot()
})

it('should be able to select a backend', () => {
  const wrapper = mountWrapper()
  wrapper.find('input[type="radio"]').simulate('change', { value: true })
  wrapper.find('button[data-testid="select"]').simulate('click')
  expect(onSelectBackend).toHaveBeenCalledWith(backend)
})
