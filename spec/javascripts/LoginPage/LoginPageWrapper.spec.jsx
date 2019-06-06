import React from 'react'
import Enzyme, {mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {SimpleLoginPage, Login3scaleForm, RequestPasswordForm} from 'LoginPage'

Enzyme.configure({adapter: new Adapter()})

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

it('should render itself with right props', () => {
  const wrapper = mount(<SimpleLoginPage {...props}/>)
  expect(wrapper.find('.pf-c-login').exists()).toEqual(true)
  expect(wrapper.props().authenticationProviders).toEqual(null)
  expect(wrapper.props().providerAdminDashboardPath).toEqual('provider-admin-path')
  expect(wrapper.props().providerLoginPath).toEqual('provider-login-path')
  expect(wrapper.props().providerPasswordPath).toEqual('password-path')
  expect(wrapper.props().providerSessionsPath).toEqual('sessions-path')
  expect(wrapper.props().redirectUrl).toEqual('redirect-url')
  expect(wrapper.props().show3scaleLoginForm).toEqual(true)
})

it('should call getURL method on mount', () => {
  const wrapper = mount(<SimpleLoginPage {...props}/>)
  wrapper.instance().getURL = jest.fn()
  wrapper.instance().componentDidMount()
  expect(wrapper.instance().getURL).toHaveBeenCalled()
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
    authenticationProviders: [{authorize_url: 'url-1'}, {authorize_url: 'url-2'}]
  }
  const wrapper = mount(<SimpleLoginPage {...propsWithProviders}/>)
  expect(wrapper.find('.providers-list').exists()).toEqual(true)
  expect(wrapper.find('#new_session').exists()).toEqual(true)
})

it('should render only Authenticaction providers when enforce SSO is enabled', () => {
  const propsEnforceSSO = {
    ...props,
    enforceSSO: true,
    authenticationProviders: [{authorize_url: 'url-1'}, {authorize_url: 'url-2'}]
  }
  const wrapper = mount(<SimpleLoginPage {...propsEnforceSSO}/>)
  expect(wrapper.find('.providers-list').exists()).toEqual(true)
  expect(wrapper.find('#new_session').exists()).toEqual(false)
})
