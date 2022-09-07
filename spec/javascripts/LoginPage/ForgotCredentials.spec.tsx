import React from 'react';
import {mount} from 'enzyme'

import {ForgotCredentials} from 'LoginPage'

const props = {
  requestPasswordResetPath: 'login-path'
} as const

it('should render itself', () => {
  const wrapper = mount(<ForgotCredentials {...props}/>)
  expect(wrapper).toMatchSnapshot()
})
