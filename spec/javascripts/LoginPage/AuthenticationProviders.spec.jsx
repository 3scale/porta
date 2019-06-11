import React from 'react'
import Enzyme, {mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

Enzyme.configure({adapter: new Adapter()})

import {AuthenticationProviders} from 'LoginPage'

const props = {
  authenticationProviders: [
    {
      authorize_url: 'fake-provider-1',
      human_kind: 'Fake human kind 1'

    }, {
      authorize_url: 'fake-provider-2',
      human_kind: 'Fake human kind 2'
    }
  ]
}

it('should render itself', () => {
  const wrapper = mount(<AuthenticationProviders {...props} />)
  expect(wrapper.find('.providers-list').exists()).toEqual(true)
  expect(wrapper.find('.login-provider').length).toEqual(2)
  expect(wrapper.find('.login-provider-link').length).toEqual(2)

  expect(wrapper.find('.login-provider-link').first().props().href).toEqual('fake-provider-1')
  expect(wrapper.find('.login-provider-link').first().contains('Fake human kind 1')).toEqual(true)

  expect(wrapper.find('.login-provider-link').last().props().href).toEqual('fake-provider-2')
  expect(wrapper.find('.login-provider-link').last().contains('Fake human kind 2')).toEqual(true)
})
