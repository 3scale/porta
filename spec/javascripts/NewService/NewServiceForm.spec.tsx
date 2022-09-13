import React, { FormEvent } from 'react'
import { act } from 'react-dom/test-utils'
import { mount } from 'enzyme'

import { NewServiceForm } from 'NewService'

// Children components that use hooks cause some nasty warnings in the log. Mocking them
// prevents react-dom.development from complaining.
import * as FOO from 'NewService/components/ServiceDiscoveryForm'
jest.mock('NewService/components/ServiceDiscoveryForm')
jest.spyOn(FOO, 'ServiceDiscoveryForm')
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
  const wrapper = mount(<NewServiceForm {...props}/>)
  expect(wrapper.find('#new_service_source').exists()).toEqual(true)
  expect(wrapper.find(`input[name='source']`).length).toEqual(2)
})

it('should render the correct form depending on which mode is selected', () => {
  const clickEvent = (value: string) => ({ currentTarget: { value } }) as unknown as FormEvent
  const wrapper = mount(<NewServiceForm {...props}/>)

  expect(wrapper.find('ServiceManualForm').exists()).toEqual(true)
  expect(wrapper.find('ServiceDiscoveryForm').exists()).toEqual(false)

  act(() => {
    wrapper.find('input#source_discover').props().onChange!(clickEvent(''))
  })

  wrapper.update()
  expect(wrapper.find('ServiceManualForm').exists()).toEqual(false)
  expect(wrapper.find('ServiceDiscoveryForm').exists()).toEqual(true)

  act(() => {
    wrapper.find('input#source_manual').props().onChange!(clickEvent('manual'))
  })

  wrapper.update()
  expect(wrapper.find('ServiceManualForm').exists()).toEqual(true)
  expect(wrapper.find('ServiceDiscoveryForm').exists()).toEqual(false)
})

describe('when Service Discovery is not accessible', () => {
  beforeAll(() => {
    props.isServiceDiscoveryAccessible = false
  })

  it('should not render service source inputs', () => {
    const wrapper = mount(<NewServiceForm {...props}/>)
    expect(wrapper.find('ServiceSourceForm').exists()).toEqual(false)
    expect(wrapper.find('input#source_manual').exists()).toEqual(false)
    expect(wrapper.find('ipnut#source_discover').exists()).toEqual(false)
  })

  it('should render new Service Manual form', () => {
    const wrapper = mount(<NewServiceForm {...props}/>)
    expect(wrapper.find('ServiceManualForm').exists()).toEqual(true)
    expect(wrapper.find('form#new_service').exists()).toEqual(true)
    expect(wrapper.find('form#service_source').exists()).toEqual(false)
  })
})
