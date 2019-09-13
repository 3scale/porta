import React from 'react'
import {mount} from 'enzyme'

import {SimpleLoginPage, Login3scaleForm, RequestPasswordForm} from 'LoginPage'

const props = {
  enforceSSO: false,
  authenticationProviders: null,
  providerAdminDashboardPath: 'provider-admin-path',
  providerLoginPath: 'provider-login-path',
  providerPasswordPath: 'password-path',
  providerSessionsPath: 'sessions-path',
  redirectUrl: 'redirect-url',
  show3scaleLoginForm: true
}

it('should render itself', () => {
  const wrapper = mount(<SimpleLoginPage {...props}/>)
  expect(wrapper.find('.pf-c-login').exists()).toEqual(true)
})

it('should call setFormMode method on mount', () => {
  const wrapper = mount(<SimpleLoginPage {...props}/>)
  wrapper.instance().setFormMode = jest.fn()
  wrapper.instance().componentDidMount()
  expect(wrapper.instance().setFormMode).toHaveBeenCalled()
})

it('should render <Login3scaleForm/> Component on mount', () => {
  const wrapper = mount(<SimpleLoginPage {...props}/>)
  wrapper.instance().componentDidMount()
  expect(wrapper.find(Login3scaleForm).exists()).toEqual(true)
})

it('should render <RequestPasswordForm/> component when formMode state is set to `password-reset`', () => {
  const wrapper = mount(<SimpleLoginPage {...props}/>)
  wrapper.setState({formMode: 'password-reset'})
  expect(wrapper.find(RequestPasswordForm).exists()).toEqual(true)
})

it('should render Login form and Authentication providers when available', () => {
  const propsWithProviders = {
    ...props,
    authenticationProviders: [{authorizeURL: 'url-1', humanKind: 'Human 1'}, {authorizeURL: 'url-2', humanKind: 'Human 2'}]
  }
  const wrapper = mount(<SimpleLoginPage {...propsWithProviders}/>)
  expect(wrapper.find('.providers-list').exists()).toEqual(true)
  expect(wrapper.find('#new_session').exists()).toEqual(true)
})

it('should render only Authenticaction providers when enforce SSO is enabled', () => {
  const propsEnforceSSO = {
    ...props,
    enforceSSO: true,
    authenticationProviders: [{authorizeURL: 'url-1', humanKind: 'Human 1'}, {authorizeURL: 'url-2', humanKind: 'Human 2'}]
  }
  const wrapper = mount(<SimpleLoginPage {...propsEnforceSSO}/>)
  expect(wrapper.find('.providers-list').exists()).toEqual(true)
  expect(wrapper.find('#new_session').exists()).toEqual(false)
})
