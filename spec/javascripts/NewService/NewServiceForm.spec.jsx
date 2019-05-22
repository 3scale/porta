import React from 'react'
import Enzyme, {mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {NewServiceForm} from 'NewService'

Enzyme.configure({adapter: new Adapter()})

describe('New Service Form', () => {
  const props = {
    isServiceDiscoveryUsable: true,
    serviceDiscoveryAuthenticateUrl: 'my-url',
    providerAdminServiceDiscoveryServicesPath: 'my-path',
    adminServicesPath: 'my-other-path'
  }

  it('should render properly', () => {
    const wrapper = mount(<NewServiceForm {...props}/>)
    expect(wrapper.find('#new_service_source').exists()).toEqual(true)
    expect(wrapper.find(`input[name='source']`).length).toEqual(2)
  })

  it('should render new Service Manual form by default', () => {
    const wrapper = mount(<NewServiceForm {...props}/>)
    expect(wrapper.find('#new_service').exists()).toEqual(true)
    expect(wrapper.find('#service_discovery').exists()).toEqual(false)
  })

  it('should render `Import from OpenShift` input not disabled when `isServiceDiscoveryUsable` is true', () => {
    const wrapper = mount(<NewServiceForm {...props}/>)
    expect(wrapper.find('#source_discover').props().disabled).toEqual(false)
  })

  it('should render `Import from OpenShift` input disabled when `isServiceDiscoveryUsable` is false', () => {
    const notUsableProps = {...props, isServiceDiscoveryUsable: false}
    const wrapper = mount(<NewServiceForm {...notUsableProps}/>)
    expect(wrapper.find('#source_discover').props().disabled).toEqual(true)
  })
})
