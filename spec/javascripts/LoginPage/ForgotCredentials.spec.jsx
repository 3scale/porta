import React from 'react'
import Enzyme, {mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {ForgotCredentials} from 'LoginPage'

Enzyme.configure({adapter: new Adapter()})
const props = {
  providerLoginPath: 'login-path'
}

it('should render itself', () => {
  const wrapper = mount(<ForgotCredentials {...props}/>)
  expect(wrapper.find('a').length).toEqual(1)
  expect(wrapper.find('a').props().href).toEqual(`${props.providerLoginPath}?request_password_reset=true`)
})
