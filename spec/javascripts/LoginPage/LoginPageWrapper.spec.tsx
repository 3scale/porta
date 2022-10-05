import { mount } from 'enzyme'
import { SimpleLoginPage } from 'LoginPage/LoginPageWrapper'

import type { Props } from 'LoginPage/LoginPageWrapper'

const props: Props = {
  authenticationProviders: [],
  providerAdminDashboardPath: 'provider-admin-path',
  providerLoginPath: 'provider-login-path',
  providerRequestPasswordResetPath: 'password-path',
  providerSessionsPath: 'sessions-path',
  redirectUrl: 'redirect-url',
  show3scaleLoginForm: true,
  disablePasswordReset: false,
  session: { username: '' }
}

it('should render itself', () => {
  const wrapper = mount(<SimpleLoginPage {...props} />)
  expect(wrapper).toMatchSnapshot()
})

it('should render reset password button when disablePasswordReset is false', () => {
  const wrapper = mount(<SimpleLoginPage {...props} />)
  expect(wrapper).toMatchSnapshot()
})

it('should not render reset password button when disablePasswordReset is true', () => {
  const propsDisabeldPasswordReset = {
    ...props,
    disablePasswordReset: true
  }
  const wrapper = mount(<SimpleLoginPage {...propsDisabeldPasswordReset} />)
  expect(wrapper).toMatchSnapshot()
})

it('should render Login form and Authentication providers when available', () => {
  const propsWithProviders = {
    ...props,
    authenticationProviders: [{ authorizeURL: 'url-1', humanKind: 'Human 1' }, { authorizeURL: 'url-2', humanKind: 'Human 2' }]
  }
  const wrapper = mount(<SimpleLoginPage {...propsWithProviders} />)
  expect(wrapper).toMatchSnapshot()
})

it('should render only Authenticaction providers when enforce SSO is enabled', () => {
  const propsEnforceSSO = {
    ...props,
    show3scaleLoginForm: false,
    authenticationProviders: [{ authorizeURL: 'url-1', humanKind: 'Human 1' }, { authorizeURL: 'url-2', humanKind: 'Human 2' }]
  }
  const wrapper = mount(<SimpleLoginPage {...propsEnforceSSO} />)
  expect(wrapper.find('form#new_session').exists()).toBe(false)
  expect(wrapper.find('.login-provider-link').exists()).toBe(true)
})
