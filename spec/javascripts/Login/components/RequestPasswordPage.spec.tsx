import { mount } from 'enzyme'

import { RequestPasswordPage } from 'Login/components/RequestPasswordPage'

import type { Props } from 'Login/components/RequestPasswordPage'

const defaultProps: Props = {
  flashMessages: [],
  providerLoginPath: 'login-path',
  providerPasswordPath: 'password-path'
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<RequestPasswordPage {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toEqual(true)
})
