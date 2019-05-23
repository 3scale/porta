import React from 'react'
import Enzyme, {shallow, mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {ServiceDiscoveryForm} from 'NewService'
import {FormWrapper, ErrorMessage,
  ServiceDiscoveryListItems} from 'NewService/components/FormElements'

Enzyme.configure({adapter: new Adapter()})

const props = {
  formActionPath: 'action-path'
}

it('should render itself', () => {
  const wrapper = shallow(<ServiceDiscoveryForm {...props}/>)
  const form = wrapper.find('#service_source')
  expect(form.exists()).toEqual(true)
  expect(form.props().formActionPath).toEqual('action-path')
})

it('should not render `ErrorMessage` child by default', () => {
  const wrapper = shallow(<ServiceDiscoveryForm {...props}/>)
  expect(wrapper.find(ErrorMessage).exists()).toEqual(false)
})

it('should render `FormWrapper` child', () => {
  const wrapper = mount(<ServiceDiscoveryForm {...props}/>)
  expect(wrapper.find(FormWrapper).exists()).toEqual(true)
})

it('should render `ServiceDiscoveryListItems` child', () => {
  const wrapper = mount(<ServiceDiscoveryForm {...props}/>)
  expect(wrapper.find(ServiceDiscoveryListItems).exists()).toEqual(true)
})
