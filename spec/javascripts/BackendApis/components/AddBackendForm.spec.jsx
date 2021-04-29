// @flow

import React from 'react'
import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { AddBackendForm } from 'BackendApis'

const backend = { id: 0, name: 'backend', privateEndpoint: 'example.org', systemName: 'backend' }
const backendsPath = '/backends'
const defaultProps = {
  backends: [backend],
  url: '',
  backendsPath
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
  const isSubmitButtonDisabled = wrapper => wrapper.find('button[data-testid="addBackend-buttonSubmit"]').prop('disabled')
  expect(isSubmitButtonDisabled(wrapper)).toBe(true)

  act(() => {
    wrapper.find('BackendSelect').prop('onSelect')(backend)
    wrapper.find('PathInput').prop('setPath')('/foo')
  })

  wrapper.update()
  expect(isSubmitButtonDisabled(wrapper)).toBe(false)
})

it('should open/close a modal with a form to create a new backend', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('NewBackendModal').prop('isOpen')).toBe(false)

  act(() => wrapper.find('button[data-testid="newBackendCreateBackend-buttonLink"]').props().onClick())
  wrapper.update()
  expect(wrapper.find('NewBackendModal').prop('isOpen')).toBe(true)

  act(() => wrapper.find('button[data-testid="cancel"]').props().onClick())
  wrapper.update()
  expect(wrapper.find('NewBackendModal').prop('isOpen')).toBe(false)
})

it('should select the new backend when created', () => {
  const wrapper = mountWrapper()
  const newBackend = { id: 1, name: 'New backend', privateEndpoint: 'example.org' }

  act(() => wrapper.find('NewBackendModal').props().onCreateBackend(newBackend))

  wrapper.update()
  expect(wrapper.find('BackendSelect').prop('backend')).toBe(newBackend)
})
