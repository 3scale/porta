import React from 'react'
import Enzyme, {mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {SignupPage} from 'LoginPage'

Enzyme.configure({adapter: new Adapter()})

const props = {
  name: 'Bob Sponge',
  path: 'bikini-bottom',
  user: {
    email: 'bob@sponge.com',
    firstname: 'Bob',
    lastname: 'Sponge',
    username: 'bobsponge',
    errors: {
      username: ['has already been taken'],
      password: ['is too short (minimum is 6 characters)']
    }
  }
}

it('should render itself', () => {
  const wrapper = mount(<SignupPage {...props}/>)
  expect(wrapper.find('.pf-c-login').exists()).toEqual(true)
})

it('should render <SignupForm/> child component', () => {
  const wrapper = mount(<SignupPage {...props}/>)
  expect(wrapper.find(SignupPage).exists()).toEqual(true)
})

it('should render error messages', () => {
  const wrapper = mount(<SignupPage {...props}/>)
  expect(wrapper.find('.pf-m-error').length).toEqual(2)
  expect(wrapper.find('.pf-m-error').at(0).text()).toContain('has already been taken')
  expect(wrapper.find('.pf-m-error').at(1).text()).toContain('is too short (minimum is 6 characters)')

})
