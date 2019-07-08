import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import { SignupForm } from 'LoginPage'

Enzyme.configure({ adapter: new Adapter() })

const props = {
  user: {
    email: 'bob@sponge.com',
    firstname: 'Bob',
    lastname: 'Sponge',
    username: 'bobsponge'
  },
  path: 'bikini-bottom'
}

it('should render itself', () => {
  const wrapper = mount(<SignupForm {...props} />)
  expect(wrapper.find('#signup_form').exists()).toEqual(true)
})

it('should render six Form Groups', () => {
  const wrapper = mount(<SignupForm {...props} />)
  expect(wrapper.find('.pf-c-form__group > label').length).toEqual(6)
})

describe('Username', () => {
  it('should render Username Form Group', () => {
    const wrapper = mount(<SignupForm {...props} />)
    expect(wrapper.find('input#user_username').length).toEqual(1)
  })
  it('should set username state', () => {
    const wrapper = mount(<SignupForm {...props} />)
    jest.spyOn(wrapper.instance(), 'handleTextInputUsername')
    wrapper.instance().handleTextInputUsername('Bob')
    expect(wrapper.instance().handleTextInputUsername).toHaveBeenCalled()
    expect(wrapper.state().username).toEqual('Bob')
  })
})

describe('Email', () => {
  it('should render Email Form Group', () => {
    const wrapper = mount(<SignupForm {...props} />)
    expect(wrapper.find('input#user_email').length).toEqual(1)
  })
  it('should set emailAddress state', () => {
    const wrapper = mount(<SignupForm {...props} />)
    jest.spyOn(wrapper.instance(), 'handleTextInputEmail')
    wrapper.instance().handleTextInputEmail('bob@sponge.com')
    expect(wrapper.instance().handleTextInputEmail).toHaveBeenCalled()
    expect(wrapper.state().emailAddress).toEqual('bob@sponge.com')
  })
})

describe('First name', () => {
  it('should render First name Form Group', () => {
    const wrapper = mount(<SignupForm {...props} />)
    expect(wrapper.find('input#user_first_name').length).toEqual(1)
  })
  it('should set firstname state', () => {
    const wrapper = mount(<SignupForm {...props} />)
    jest.spyOn(wrapper.instance(), 'handleTextInputFirstname')
    wrapper.instance().handleTextInputFirstname('Patrick')
    expect(wrapper.instance().handleTextInputFirstname).toHaveBeenCalled()
    expect(wrapper.state().firstname).toEqual('Patrick')
  })
})

describe('Last name', () => {
  it('should render Last name Form Group', () => {
    const wrapper = mount(<SignupForm {...props} />)
    expect(wrapper.find('input#user_last_name').length).toEqual(1)
  })
  it('should set lastname state', () => {
    const wrapper = mount(<SignupForm {...props} />)
    jest.spyOn(wrapper.instance(), 'handleTextInputLastname')
    wrapper.instance().handleTextInputLastname('Star')
    expect(wrapper.instance().handleTextInputLastname).toHaveBeenCalled()
    expect(wrapper.state().lastname).toEqual('Star')
  })
})

describe('Password', () => {
  it('should render Password Form Group', () => {
    const wrapper = mount(<SignupForm {...props} />)
    expect(wrapper.find('input#user_password').length).toEqual(1)
  })
  it('should set password state', () => {
    const wrapper = mount(<SignupForm {...props} />)
    jest.spyOn(wrapper.instance(), 'handleTextInputPassword')
    wrapper.instance().handleTextInputPassword('gary1234')
    expect(wrapper.instance().handleTextInputPassword).toHaveBeenCalled()
    expect(wrapper.state().password).toEqual('gary1234')
  })
})

describe('Password confirmation', () => {
  it('should render Password confirmation Form Group', () => {
    const wrapper = mount(<SignupForm {...props} />)
    expect(wrapper.find('input#user_password_confirmation').length).toEqual(1)
  })
  it('should set passwordConfirmation state', () => {
    const wrapper = mount(<SignupForm {...props} />)
    jest.spyOn(wrapper.instance(), 'handleTextInputPasswordConfirmation')
    wrapper.instance().handleTextInputPasswordConfirmation('gary1234')
    expect(wrapper.instance().handleTextInputPasswordConfirmation).toHaveBeenCalled()
    expect(wrapper.state().passwordConfirmation).toEqual('gary1234')
  })
})
