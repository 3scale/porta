import React from 'react'
import {mount} from 'enzyme'

import {ForgotCredentials} from 'LoginPage'

const props = {
  providerLoginPath: 'login-path'
}

it('should render itself', () => {
  const wrapper = mount(<ForgotCredentials {...props}/>)
  expect(wrapper.find('a').length).toEqual(1)
  expect(wrapper.find('a').props().href).toEqual(`${props.providerLoginPath}?request_password_reset=true`)
})
