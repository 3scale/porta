import { mount } from 'enzyme'

import { AuthenticationProviders } from 'LoginPage/loginForms/AuthenticationProviders'

import type { Props } from 'LoginPage/loginForms/AuthenticationProviders'

const props: Props = {
  authenticationProviders: [{
    authorizeURL: 'fake-provider-1',
    humanKind: 'Fake human kind 1'

  }, {
    authorizeURL: 'fake-provider-2',
    humanKind: 'Fake human kind 2'
  }]
}

it('should render itself', () => {
  const wrapper = mount(<AuthenticationProviders {...props} />)
  expect(wrapper.find('.providers-list').exists()).toEqual(true)
  expect(wrapper.find('.login-provider').length).toEqual(2)
  expect(wrapper.find('.login-provider-link').length).toEqual(2)

  expect(wrapper.find('.login-provider-link').first().props().href).toEqual('fake-provider-1')
  expect(wrapper.find('.login-provider-link').first().text()).toMatch('Fake human kind 1')

  expect(wrapper.find('.login-provider-link').last().props().href).toEqual('fake-provider-2')
  expect(wrapper.find('.login-provider-link').last().text()).toMatch('Fake human kind 2')
})
