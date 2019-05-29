import React from 'react'
import Enzyme, {shallow, mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {ServiceManualForm} from 'NewService'
import {FormWrapper, ServiceManualListItems} from 'NewService/components/FormElements'

Enzyme.configure({adapter: new Adapter()})

const props = {
  formActionPath: 'action-path'
}

it('should render itself', () => {
  const wrapper = shallow(<ServiceManualForm {...props}/>)
  const form = wrapper.find('#new_service')
  expect(form.exists()).toEqual(true)
  expect(form.props().formActionPath).toEqual('action-path')
})

it('should render `FormWrapper` child', () => {
  const wrapper = mount(<ServiceManualForm {...props}/>)
  expect(wrapper.find(FormWrapper).exists()).toEqual(true)
})

it('should render `ServiceManualListItems` child', () => {
  const wrapper = mount(<ServiceManualForm {...props}/>)
  expect(wrapper.find(ServiceManualListItems).exists()).toEqual(true)
})
