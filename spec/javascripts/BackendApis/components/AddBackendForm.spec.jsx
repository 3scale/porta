// @flow

import React from 'react'
import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { AddBackendForm } from 'BackendApis'

const backend = { id: 0, name: 'backend', privateEndpoint: 'example.org' }
const newBackendPath = '/backend/new'
const defaultProps = {
  backends: [backend],
  url: '',
  newBackendPath
}

const mountWrapper = (props) => mount(<AddBackendForm {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should enable submit button only when form is filled', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('button[data-testid="submit"]').prop('disabled')).toBe(true)

  act(() => {
    wrapper.find('BackendSelect').prop('onSelect')(backend)
    wrapper.find('PathInput').prop('setPath')('/foo')
  })

  wrapper.update()
  expect(wrapper.find('button[data-testid="submit"]').prop('disabled')).toBe(false)
})

it('should have a button to create a new backend', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find(`a[href="${newBackendPath}"]`))
})
