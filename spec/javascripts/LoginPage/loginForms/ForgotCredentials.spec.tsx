import { mount } from 'enzyme'

import { ForgotCredentials } from 'Login/components/ForgotCredentials'

import type { Props } from 'Login/components/ForgotCredentials'

const props: Props = {
  requestPasswordResetPath: 'login-path'
}

it('should render itself', () => {
  const wrapper = mount(<ForgotCredentials {...props} />)
  expect(wrapper).toMatchSnapshot()
})
