import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { NewServiceForm } from 'NewService/components/NewServiceForm'
// Children components that use hooks cause some nasty warnings in the log. Mocking them prevents react-dom.development from complaining.
import * as FOO from 'NewService/components/ServiceDiscoveryForm'

import type { FormEvent } from 'react'

jest.mock('NewService/components/ServiceDiscoveryForm')
jest.spyOn(FOO, 'ServiceDiscoveryForm')
  // eslint-disable-next-line react/jsx-no-useless-fragment
  .mockImplementation(() => (<></>))

const props = {
  template: {
    service: {
      name: 'New API',
      system_name: 'new_api',
      description: 'A brand new API'
    },
    errors: {}
  },
  isServiceDiscoveryAccessible: true,
  isServiceDiscoveryUsable: true,
  serviceDiscoveryAuthenticateUrl: 'authenticate-url',
  providerAdminServiceDiscoveryServicesPath: 'my-path',
  adminServicesPath: 'my-other-path',
  backendApis: []
}

it('should render itself', () => {
  const wrapper = mount(<NewServiceForm {...props} />)
  expect(wrapper.exists('#new_service_source')).toEqual(true)
  expect(wrapper.find('input[name=\'source\']').length).toEqual(2)
})

it('should render the correct form depending on which mode is selected', () => {
  const clickEvent = (value: string) => ({ currentTarget: { value } }) as unknown as FormEvent
  const wrapper = mount(<NewServiceForm {...props} />)

  expect(wrapper.exists('ServiceManualForm')).toEqual(true)
  expect(wrapper.exists('ServiceDiscoveryForm')).toEqual(false)

  act(() => {
    wrapper.find('input#source_discover').props().onChange!(clickEvent(''))
  })

  wrapper.update()
  expect(wrapper.exists('ServiceManualForm')).toEqual(false)
  expect(wrapper.exists('ServiceDiscoveryForm')).toEqual(true)

  act(() => {
    wrapper.find('input#source_manual').props().onChange!(clickEvent('manual'))
  })

  wrapper.update()
  expect(wrapper.exists('ServiceManualForm')).toEqual(true)
  expect(wrapper.exists('ServiceDiscoveryForm')).toEqual(false)
})

describe('when Service Discovery is not accessible', () => {
  beforeAll(() => {
    props.isServiceDiscoveryAccessible = false
  })

  it('should not render service source inputs', () => {
    const wrapper = mount(<NewServiceForm {...props} />)
    expect(wrapper.exists('ServiceSourceForm')).toEqual(false)
    expect(wrapper.exists('input#source_manual')).toEqual(false)
    expect(wrapper.exists('ipnut#source_discover')).toEqual(false)
  })

  it('should render new Service Manual form', () => {
    const wrapper = mount(<NewServiceForm {...props} />)
    expect(wrapper.exists('ServiceManualForm')).toEqual(true)
    expect(wrapper.exists('form#new_service')).toEqual(true)
    expect(wrapper.exists('form#service_source')).toEqual(false)
  })
})
