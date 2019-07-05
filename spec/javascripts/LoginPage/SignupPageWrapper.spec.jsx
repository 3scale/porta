import React from 'react'
import Enzyme, {mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {SignupPage, SignupForm} from 'LoginPage'

Enzyme.configure({adapter: new Adapter()})

const props = {
  name: 'Bob Sponge',
  path: 'bikini-bottom'
}

it('should render itself', () => {
  const wrapper = mount(<SignupPage {...props}/>)
  expect(wrapper.find('.pf-c-login').exists()).toEqual(true)
})

it('should render <SignupForm/> child component', () => {
  const wrapper = mount(<SignupPage {...props}/>)
  expect(wrapper.find(SignupPage).exists()).toEqual(true)
})
