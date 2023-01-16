import { mount } from 'enzyme'

import { NewBackendModal } from 'BackendApis/components/NewBackendModal'

import type { Props } from 'BackendApis/components/NewBackendModal'

const defaultProps = {
  backendsPath: '/backends',
  isOpen: true,
  onClose: jest.fn(),
  onCreateBackend: jest.fn()
} as const

const mountWrapper = (props: Partial<Props> = {}) => mount(<NewBackendModal {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

// This component is really hard to test via JS since it uses jQuery and jquery-ujs.
it.todo('should display a spinner when loading')
it.todo('should close after creating a backend')
it.todo('should show validation errors when creation fails')
