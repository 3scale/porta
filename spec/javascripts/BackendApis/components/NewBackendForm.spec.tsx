import React from 'react'
import { act } from 'react-dom/test-utils'
import { mount, ReactWrapper } from 'enzyme'

import { NewBackendForm, Props } from 'BackendApis/components/NewBackendForm'
import { NameInput } from 'BackendApis/components/NameInput'
import { PrivateEndpointInput } from 'BackendApis/components/PrivateEndpointInput'
import { SystemNameInput } from 'BackendApis/components/SystemNameInput'

const validNames = [
  'M',
  'My Backend',
  '!"·$%&/()=?¿^*¨Ç_-´ç`+¡ºª\\|@#÷“”≠´‚[]}{~'
]

const invalidNames = [
  ''
]

const validSystemNames = [
  '',
  'name',
  'some-system-name',
  'another_one',
  'thismakes4',
  'this/is/also/valid',
  '_AND_THIS_ONE'
]

const invalidSystemNames = [
  '/invalid',
  '-invalid',
  'nope!!',
  'err...no',
  'try_@gain',
  ' '
]

const validPaths = [
  'http://example.com',
  'https://example-with-dash.com',
  'https://example.com:3000',
  'ws://example.com',
  'wss://example.com',
  'ws://example.com:2222',
  'wss://example.com:2222',
  'http://224.0.0.1',
  'https://224.0.0.1'
]

const invalidPaths = [
  '',
  'foo',
  'ftp://wrong-schema.org',
  'www.need.shchema.org'
]

const defaultProps = {
  action: '/backends',
  onCancel: () => {},
  isLoading: false,
  errors: undefined
} as const

const mountWrapper = (props: Partial<Props> = {}) => mount(<NewBackendForm {...{ ...defaultProps, ...props }} />)
const isSubmitButtonDisabled = (wrapper: ReactWrapper): boolean => Boolean(wrapper.find('button[data-testid="newBackendCreateBackend-buttonSubmit"]').prop('disabled'))

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should enable submit button only when form is filled with required data', () => {
  const wrapper = mountWrapper()
  expect(isSubmitButtonDisabled(wrapper)).toBe(true)

  act(() => {
    wrapper.find(NameInput).props().setName('My Backend API')
    wrapper.find(PrivateEndpointInput).props().setPrivateEndpoint('')
  })
  wrapper.update()
  expect(isSubmitButtonDisabled(wrapper)).toBe(true)

  act(() => {
    wrapper.find(NameInput).props().setName('')
    wrapper.find(PrivateEndpointInput).props().setPrivateEndpoint(validPaths[0])
  })
  wrapper.update()
  expect(isSubmitButtonDisabled(wrapper)).toBe(true)

  act(() => {
    wrapper.find(NameInput).props().setName('My Backend API')
    wrapper.find(PrivateEndpointInput).props().setPrivateEndpoint(validPaths[0])
  })
  wrapper.update()
  expect(isSubmitButtonDisabled(wrapper)).toBe(false)
})

it('should enable submit button only when name is valid', () => {
  const wrapper = mountWrapper()
  expect(isSubmitButtonDisabled(wrapper)).toBe(true)
  act(() => wrapper.find(PrivateEndpointInput).props().setPrivateEndpoint(validPaths[0]))

  invalidNames.forEach(name => {
    act(() => wrapper.find(NameInput).props().setName(name))
    wrapper.update()
    expect(isSubmitButtonDisabled(wrapper)).toBe(true)
  })

  validNames.forEach(name => {
    act(() => wrapper.find(NameInput).props().setName(name))
    wrapper.update()
    expect(isSubmitButtonDisabled(wrapper)).toBe(false)
  })
})

it('should enable submit button only when system name is empty or valid', () => {
  const wrapper = mountWrapper()
  act(() => {
    wrapper.find(NameInput).props().setName(validNames[0])
    wrapper.find(PrivateEndpointInput).props().setPrivateEndpoint(validPaths[0])
  })
  wrapper.update()
  expect(isSubmitButtonDisabled(wrapper)).toBe(false)

  invalidSystemNames.forEach(systemName => {
    act(() => wrapper.find(SystemNameInput).props().setSystemName(systemName))
    wrapper.update()
    expect(isSubmitButtonDisabled(wrapper)).toBe(true)
  })

  validSystemNames.forEach(systemName => {
    act(() => wrapper.find(SystemNameInput).props().setSystemName(systemName))
    wrapper.update()
    expect(isSubmitButtonDisabled(wrapper)).toBe(false)
  })
})

it('should enable submit button only when private endpoint is valid', () => {
  const wrapper = mountWrapper()
  expect(isSubmitButtonDisabled(wrapper)).toBe(true)
  act(() => wrapper.find(NameInput).props().setName(validNames[0]))

  invalidPaths.forEach(path => {
    act(() => wrapper.find(PrivateEndpointInput).props().setPrivateEndpoint(path))
    wrapper.update()
    expect(isSubmitButtonDisabled(wrapper)).toBe(true)
  })

  validPaths.forEach(path => {
    act(() => wrapper.find(PrivateEndpointInput).props().setPrivateEndpoint(path))
    wrapper.update()
    expect(isSubmitButtonDisabled(wrapper)).toBe(false)
  })
})

describe('when loading', () => {
  const props = { isLoading: true } as const

  it('should have its submit button disabled', () => {
    const wrapper = mountWrapper(props)

    act(() => {
      wrapper.find(NameInput).props().setName('My Backend API')
      wrapper.find(PrivateEndpointInput).props().setPrivateEndpoint(validPaths[0])
    })

    wrapper.update()
    expect(isSubmitButtonDisabled(wrapper)).toBe(true)
  })
})
