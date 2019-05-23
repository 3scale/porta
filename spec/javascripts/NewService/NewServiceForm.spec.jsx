import React from 'react'
import Enzyme, {mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {NewServiceForm} from 'NewService'

Enzyme.configure({adapter: new Adapter()})

const props = {
  isServiceDiscoveryUsable: true,
  serviceDiscoveryAuthenticateUrl: 'authenticate-url',
  providerAdminServiceDiscoveryServicesPath: 'my-path',
  adminServicesPath: 'my-other-path'
}
const discoveryNotUsableProps = {
  ...props,
  isServiceDiscoveryUsable: false
}

it('should render itself', () => {
  const wrapper = mount(<NewServiceForm {...props}/>)
  expect(wrapper.find('#new_service_source').exists()).toEqual(true)
  expect(wrapper.find(`input[name='source']`).length).toEqual(2)
})

it('should render new Service Manual form', () => {
  const wrapper = mount(<NewServiceForm {...props}/>)
  expect(wrapper.find('#new_service').exists()).toEqual(true)
  expect(wrapper.find('#service_discovery').exists()).toEqual(false)
})

// TODO: remove `skip` when this is merged: https://github.com/airbnb/enzyme/pull/2008
it.skip('should render new Service Discovery form when click on input', () => {
  const wrapper = mount(<NewServiceForm {...props}/>)
  wrapper.find('#source_discover').simulate('click')
  wrapper.update()
  expect(wrapper.find('#new_service').exists()).toEqual(false)
  expect(wrapper.find('#service_discovery').exists()).toEqual(true)
})

it('should render `Import from OpenShift` input not disabled when `isServiceDiscoveryUsable` is true', () => {
  const wrapper = mount(<NewServiceForm {...props}/>)
  expect(wrapper.find('#source_discover').props().disabled).toEqual(false)
})

it('should render `Import from OpenShift` input disabled when `isServiceDiscoveryUsable` is false', () => {
  const wrapper = mount(<NewServiceForm {...discoveryNotUsableProps}/>)
  expect(wrapper.find('#source_discover').props().disabled).toEqual(true)
})

it('should render `(Authenticate to enable this option)` link when `isServiceDiscoveryUsable` is false', () => {
  const wrapper = mount(<NewServiceForm {...discoveryNotUsableProps}/>)
  const link = wrapper.find(`label[htmlFor='source_discover'] a`)
  expect(link.exists()).toEqual(true)
  expect(link.props().href).toEqual('authenticate-url')
})
