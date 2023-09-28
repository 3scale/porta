import { mount } from 'enzyme'

import { LoginPage } from 'Login/components/LoginPage'

import type { Props } from 'Login/components/LoginPage'

const defaultProps: Props = {
  flashMessages: [],
  authenticationProviders: [],
  providerRequestPasswordResetPath: 'password-path',
  providerSessionsPath: 'sessions-path',
  show3scaleLoginForm: true,
  disablePasswordReset: false,
  session: { username: '' }
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<LoginPage {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper).toMatchSnapshot()
})

it('should render reset password button when disablePasswordReset is false', () => {
  const wrapper = mountWrapper()
  expect(wrapper).toMatchSnapshot()
})

it('should not render reset password button when disablePasswordReset is true', () => {
  const wrapper = mountWrapper({ disablePasswordReset: true })
  expect(wrapper).toMatchSnapshot()
})

it('should render Login form and Authentication providers when available', () => {
  const authenticationProviders =  [
    { authorizeURL: 'url-1', humanKind: 'Human 1' },
    { authorizeURL: 'url-2', humanKind: 'Human 2' }
  ]
  const wrapper = mountWrapper({ authenticationProviders })
  expect(wrapper).toMatchSnapshot()
})

it('should render only Authenticaction providers when enforce SSO is enabled', () => {
  const authenticationProviders = [
    { authorizeURL: 'url-1', humanKind: 'Human 1' },
    { authorizeURL: 'url-2', humanKind: 'Human 2' }
  ]
  const wrapper = mountWrapper({ show3scaleLoginForm: false, authenticationProviders })
  expect(wrapper.exists('form#new_session')).toEqual(false)
  expect(wrapper.exists('.login-provider-link')).toEqual(true)
})
