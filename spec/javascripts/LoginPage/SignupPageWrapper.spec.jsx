// @flow

import React from 'react'
import {mount} from 'enzyme'

import {SignupPage} from 'LoginPage'

const props = {
  name: 'Bob Sponge',
  path: 'bikini-bottom',
  user: {
    email: 'bob@sponge.com',
    firstname: 'Bob',
    lastname: 'Sponge',
    username: 'bobsponge',
    errors: [
      {type: 'error', message: 'username has already been taken'},
      {type: 'error', message: 'password is too short (minimum is 6 characters)'}
    ]
  }
}

it('should render itself', () => {
  const wrapper = mount(<SignupPage {...props}/>)
  expect(wrapper.find('.pf-c-login').exists()).toEqual(true)
})

it('should render <SignupForm/> child component', () => {
  const wrapper = mount(<SignupPage {...props}/>)
  expect(wrapper.find('SignupForm').exists()).toEqual(true)
})

it('should render error messages', () => {
  const wrapper = mount(<SignupPage {...props}/>)
  expect(wrapper.find('.pf-m-error').length).toEqual(2)
  expect(wrapper.find('.pf-m-error').at(0).text()).toContain('username has already been taken')
  expect(wrapper.find('.pf-m-error').at(1).text()).toContain('password is too short (minimum is 6 characters)')
})
