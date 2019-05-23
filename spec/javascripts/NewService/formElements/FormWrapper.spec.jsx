import React from 'react'
import Enzyme, {mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {FormWrapper} from 'NewService/components/FormElements'
import {HiddenServiceDiscoveryInput} from 'NewService/components/FormElements'
import {CSRFToken} from 'utilities/utils'

Enzyme.configure({adapter: new Adapter()})

const props = {
  id: 'form-id',
  formActionPath: 'my-path',
  hasHiddenServiceDiscoveryInput: true,
  submitText: 'Add API'
}

it('should render itself', () => {
  const wrapper = mount(<FormWrapper {...props}/>)
  expect(wrapper.find('#form-id').exists()).toEqual(true)
})

it('should render submit button with proper text', () => {
  const wrapper = mount(<FormWrapper {...props}/>)
  expect(wrapper.find(`input[type='submit']`).props().value).toEqual('Add API')
  expect(wrapper.find(HiddenServiceDiscoveryInput).exists()).toEqual(true)
  expect(wrapper.find(CSRFToken).exists()).toEqual(true)
})

it('should render `HiddenServiceDiscoveryInput` child', () => {
  const wrapper = mount(<FormWrapper {...props}/>)
  expect(wrapper.find(HiddenServiceDiscoveryInput).exists()).toEqual(true)
})

it('should render `CSRFToken` child', () => {
  const wrapper = mount(<FormWrapper {...props}/>)
  expect(wrapper.find(CSRFToken).exists()).toEqual(true)
})
