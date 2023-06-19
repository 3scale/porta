import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { NewPage } from 'Products/components/NewPage'
import { ServiceDiscoveryForm } from 'Products/components/ServiceDiscoveryForm'
import { ManualForm } from 'Products/components/ManualForm'

import type { Props } from 'Products/components/NewPage'
import type { FormEvent } from 'react'
import { toggleElementInCollection } from 'Users/utils'

const defaultProps = {
  service: {
    name: 'New API',
    system_name: 'new_api',
    description: 'A brand new API',
    errors: {}
  },
  isServiceDiscoveryAccessible: false,
  isServiceDiscoveryUsable: false,
  serviceDiscoveryAuthenticateUrl: 'authenticate-url',
  providerAdminServiceDiscoveryServicesPath: 'my-path',
  adminServicesPath: 'my-other-path'
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<NewPage {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})

describe('when Service Discovery is not accessible', () => {
  const props = { isServiceDiscoveryAccessible: false }

  it('should render the manual form only', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.exists(ManualForm)).toEqual(true)
    expect(wrapper.exists(ServiceDiscoveryForm)).toEqual(false)

    expect(wrapper.exists('#radio-manual')).toEqual(false)
    expect(wrapper.exists('#radio-service-discovery')).toEqual(false)
  })
})

describe('when Service Discovery is accessible', () => {
  const props = { isServiceDiscoveryAccessible: true }

  it('should show the manual form by default', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.exists(ManualForm)).toEqual(true)
    expect(wrapper.exists(ServiceDiscoveryForm)).toEqual(false)
  })

  it('should be able to switch between manual and service discovery', () => {
    const wrapper = mountWrapper(props)

    act(() => {
      // eslint-disable-next-line @typescript-eslint/no-unsafe-argument -- Simulate event
      wrapper.find('input#radio-service-discovery').props().onChange!({ currentTarget: {} } as any)
    })

    wrapper.update()
    expect(wrapper.find('input#radio-service-discovery').props().checked).toEqual(true)
    expect(wrapper.exists(ManualForm)).toEqual(false)
    expect(wrapper.exists(ServiceDiscoveryForm)).toEqual(true)

    act(() => {
      // eslint-disable-next-line @typescript-eslint/no-unsafe-argument -- Simulate event
      wrapper.find('input#radio-manual').props().onChange!({ currentTarget: {} } as any)
    })

    wrapper.update()
    expect(wrapper.find('input#radio-manual').props().checked).toEqual(true)
    expect(wrapper.exists(ManualForm)).toEqual(true)
    expect(wrapper.exists(ServiceDiscoveryForm)).toEqual(false)
  })

  it('should disable the radio buttons when loading projects', () => {
    const wrapper = mountWrapper(props)

    act(() => {
      // eslint-disable-next-line @typescript-eslint/no-unsafe-argument -- Simulate event
      wrapper.find('input#radio-service-discovery').props().onChange!({ currentTarget: {} } as any)
    })

    act(() => {
      wrapper.update().find(ServiceDiscoveryForm).props().setLoadingProjects(true)
    })

    wrapper.update()
    expect(wrapper.find('input#radio-manual').props().disabled).toEqual(true)
    expect(wrapper.find('input#radio-service-discovery').props().disabled).toEqual(true)
  })
})

describe('when Service Discovery is accessible but not usable', () => {
  const props = { isServiceDiscoveryAccessible: true, isServiceDiscoveryUsable: false }

  it('should need to authenticate', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.exists(`a[href="${defaultProps.serviceDiscoveryAuthenticateUrl}"]`)).toEqual(true)
    expect(wrapper.find('input#radio-service-discovery').props().disabled).toEqual(true)
  })
})

describe('when Service Discovery is accessible and usable', () => {
  const props = { isServiceDiscoveryAccessible: true, isServiceDiscoveryUsable: true }

  it('should not need to authenticate', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.exists(`a[href="${defaultProps.serviceDiscoveryAuthenticateUrl}"]`)).toEqual(false)
  })
})
