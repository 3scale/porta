import React from 'react';
import {shallow, mount} from 'enzyme'

import {ServiceManualForm} from 'NewService'
import {FormWrapper, ServiceManualListItems} from 'NewService/components/FormElements'

const props = {
  backendApis: [],
  template: {
    service: {
      name: 'New API',
      system_name: 'new_api',
      description: 'A brand new API'
    },
    errors: {}
  },
  formActionPath: 'action-path'
} as const

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
