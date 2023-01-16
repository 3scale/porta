import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { PrivateEndpointInput } from 'BackendApis/components/PrivateEndpointInput'

import type { Props } from 'BackendApis/components/PrivateEndpointInput'

const defaultProps = {
  privateEndpoint: '',
  setPrivateEndpoint: jest.fn()
} as const

const mountWrapper = (props: Partial<Props> = {}) => mount(<PrivateEndpointInput {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

it('should work', () => {
  const value = 'foo'
  const setPrivateEndpoint = jest.fn()
  const wrapper = mountWrapper({ setPrivateEndpoint })

  act(() => { wrapper.find(PrivateEndpointInput).props().setPrivateEndpoint(value) })

  wrapper.update()
  expect(setPrivateEndpoint).toHaveBeenCalledWith(value)
})
