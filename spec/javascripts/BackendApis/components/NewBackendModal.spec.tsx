import React from 'react';
import { mount } from 'enzyme'

import { NewBackendModal } from 'BackendApis'

const defaultProps = {
  backendsPath: '/backends',
  isOpen: true,
  onClose: () => {},
  onCreateBackend: () => {}
} as const

const mountWrapper = (props: undefined) => mount(<NewBackendModal {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

// This component is really hard to test via JS since it uses jQuery and jquery-ujs.
it.todo('should display a spinner when loading')
it.todo('should close after creating a backend')
it.todo('should show validation errors when creation fails')
