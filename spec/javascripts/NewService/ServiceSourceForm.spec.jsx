import React from 'react'
import Enzyme, {shallow} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {ServiceSourceForm} from 'NewService'

Enzyme.configure({adapter: new Adapter()})

const props = {
  isServiceDiscoveryUsable: true,
  serviceDiscoveryAuthenticateUrl: 'my-url',
  handleFormsVisibility: jest.fn()
}

it('should render itself', () => {
  const wrapper = shallow(<ServiceSourceForm {...props}/>)
  expect(wrapper.find('#new_service_source').exists()).toEqual(true)
})

it('should call `handleFormsVisibility`', () => {
  const wrapper = shallow(<ServiceSourceForm {...props}/>)
  wrapper.find('#source_discover').simulate('change')
  expect(props.handleFormsVisibility).toHaveBeenCalled()
})

it('should render `Import from OpenShift` input disabled when Service Discovery is not usable', () => {
  const propsNotUsable = {...props, isServiceDiscoveryUsable: false}
  const wrapper = shallow(<ServiceSourceForm {...propsNotUsable}/>)
  expect(wrapper.find('#source_discover + span').text()).toEqual('Import from OpenShift')
  expect(wrapper.find('#source_discover').props().disabled).toEqual(true)
})
