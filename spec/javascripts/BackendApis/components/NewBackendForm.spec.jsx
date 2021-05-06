// @flow

import React from 'react'
import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { NewBackendForm } from 'BackendApis'

const validPaths = [
  'http://example.com',
  'https://example.com',
  'ws://example.com',
  'wss://example.com',
  'http://example.com:3000'
]

const invalidPaths = [
  'foo',
  'ftp://exaple.org',
  'www.example.org'
]

const defaultProps = {
  action: '/backends',
  onCancel: () => {},
  isLoading: false,
  errors: undefined
}

const mountWrapper = (props) => mount(<NewBackendForm {...{ ...defaultProps, ...props }} />)
const isSubmitButtonDisabled = wrapper => wrapper.find('button[data-testid="newBackendCreateBackend-buttonSubmit"]').prop('disabled')

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should enable submit button only when form is filled', () => {
  const wrapper = mountWrapper()
  expect(isSubmitButtonDisabled(wrapper)).toBe(true)

  act(() => {
    wrapper.find('NameInput').props().setName('My Backend API')
    wrapper.find('PrivateEndpointInput').props().setPrivateEndpoint('')
  })
  wrapper.update()
  expect(isSubmitButtonDisabled(wrapper)).toBe(true)

  act(() => {
    wrapper.find('NameInput').props().setName('')
    wrapper.find('PrivateEndpointInput').props().setPrivateEndpoint(validPaths[0])
  })
  wrapper.update()
  expect(isSubmitButtonDisabled(wrapper)).toBe(true)

  act(() => {
    wrapper.find('NameInput').props().setName('My Backend API')
    wrapper.find('PrivateEndpointInput').props().setPrivateEndpoint(validPaths[0])
  })
  wrapper.update()
  expect(isSubmitButtonDisabled(wrapper)).toBe(false)
})

it('should enable submit button only when form is valid', () => {
  const wrapper = mountWrapper()
  expect(isSubmitButtonDisabled(wrapper)).toBe(true)
  act(() => wrapper.find('NameInput').props().setName('My Backend API'))

  invalidPaths.forEach(path => {
    act(() => wrapper.find('PrivateEndpointInput').props().setPrivateEndpoint(path))
    wrapper.update()
    expect(isSubmitButtonDisabled(wrapper)).toBe(true)
  })

  validPaths.forEach(path => {
    act(() => wrapper.find('PrivateEndpointInput').props().setPrivateEndpoint(path))
    wrapper.update()
    expect(isSubmitButtonDisabled(wrapper)).toBe(false)
  })
})

describe('when loading', () => {
  const props = { isLoading: true }

  it('should have its submit button disabled', () => {
    const wrapper = mountWrapper(props)

    act(() => {
      wrapper.find('NameInput').props().setName('My Backend API')
      wrapper.find('PrivateEndpointInput').props().setPrivateEndpoint(validPaths[0])
    })

    wrapper.update()
    expect(isSubmitButtonDisabled(wrapper)).toBe(true)
  })
})
