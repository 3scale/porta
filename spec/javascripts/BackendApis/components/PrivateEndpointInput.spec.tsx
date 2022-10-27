import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { PrivateEndpointInput } from 'BackendApis/components/PrivateEndpointInput'

import type { Props } from 'BackendApis/components/PrivateEndpointInput'

const setPrivateEndpoint = jest.fn()

const defaultProps = {
  privateEndpoint: '',
  setPrivateEndpoint
} as const

const mountWrapper = (props: Partial<Props> = {}) => mount(<PrivateEndpointInput {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should work', () => {
  const value = 'foo'
  const wrapper = mountWrapper()

  act(() => { wrapper.find(PrivateEndpointInput).props().setPrivateEndpoint(value) })

  wrapper.update()
  expect(setPrivateEndpoint).toHaveBeenCalledWith(value)
})
