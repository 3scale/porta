import { mount } from 'enzyme'

import { ForgotCredentials } from 'LoginPage/loginForms/ForgotCredentials'

import type { Props } from 'LoginPage/loginForms/ForgotCredentials'

const props: Props = {
  requestPasswordResetPath: 'login-path'
}

it('should render itself', () => {
  const wrapper = mount(<ForgotCredentials {...props} />)
  expect(wrapper).toMatchSnapshot()
})
