// @flow

import React from 'react'
import Enzyme, {mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {NewServiceForm, ServiceManualForm, ServiceDiscoveryForm} from 'NewService'

import * as utils from 'utilities/utils'
jest.spyOn(utils, 'CSRFToken')
  .mockImplementation(() => '')

Enzyme.configure({adapter: new Adapter()})

const props = {
  isServiceDiscoveryAccessible: true,
  isServiceDiscoveryUsable: true,
  serviceDiscoveryAuthenticateUrl: 'authenticate-url',
  providerAdminServiceDiscoveryServicesPath: 'my-path',
  adminServicesPath: 'my-other-path'
}

it('should render itself', () => {
  const wrapper = mount(<NewServiceForm {...props}/>)
  expect(wrapper.find('#new_service_source').exists()).toEqual(true)
  expect(wrapper.find(`input[name='source']`).length).toEqual(2)
})

it('should render the correct form depending on which mode is selected', () => {
  const wrapper = mount(<NewServiceForm {...props}/>)
  const clickEvent = value => ({ currentTarget: { value } })

  wrapper.find('input#source_discover').props().onChange(clickEvent(''))
  wrapper.update()
  expect(wrapper.find(ServiceManualForm).exists()).toEqual(false)
  expect(wrapper.find(ServiceDiscoveryForm).exists()).toEqual(true)

  wrapper.find('input#source_manual').props().onChange(clickEvent('manual'))
  wrapper.update()
  expect(wrapper.find(ServiceManualForm).exists()).toEqual(true)
  expect(wrapper.find(ServiceDiscoveryForm).exists()).toEqual(false)
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
