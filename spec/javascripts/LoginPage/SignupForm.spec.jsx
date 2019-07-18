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
  const event = {
    currentTarget: {
      name: 'username',
      value: 'Bob',
      type: 'text'
    }
  }
  it('should render Username Form Group', () => {
    const wrapper = mount(<SignupForm {...props} />)
    expect(wrapper.find('input#user_username').length).toEqual(1)
  })
  it('should set username state', () => {
    const wrapper = mount(<SignupForm {...props} />)
    jest.spyOn(wrapper.instance(), 'handleInputChange')
    wrapper.instance().handleInputChange('Bob', event)
    expect(wrapper.instance().handleInputChange).toHaveBeenCalled()
    expect(wrapper.state().username).toEqual('Bob')
  })
})

describe('Email', () => {
  const event2 = {
    currentTarget: {
      name: 'user[email]',
      value: 'bob@sponge.com',
      type: 'email'
    }
  }
  it('should render Email Form Group', () => {
    const wrapper = mount(<SignupForm {...props} />)
    expect(wrapper.find('input#user_email').length).toEqual(1)
  })
  it('should set emailAddress state', () => {
    const wrapper = mount(<SignupForm {...props} />)
    jest.spyOn(wrapper.instance(), 'handleInputChange')
    wrapper.instance().handleInputChange('bob@sponge.com', event2)
    expect(wrapper.instance().handleInputChange).toHaveBeenCalled()
    expect(wrapper.state().emailAddress).toEqual('bob@sponge.com')
  })
})

describe('First name', () => {
  const event = {
    currentTarget: {
      name: 'user[first_name]',
      value: 'Patrick',
      type: 'text'
    }
  }
  it('should render First name Form Group', () => {
    const wrapper = mount(<SignupForm {...props} />)
    expect(wrapper.find('input#user_first_name').length).toEqual(1)
  })
  it('should set firstname state', () => {
    const wrapper = mount(<SignupForm {...props} />)
    jest.spyOn(wrapper.instance(), 'handleInputChange')
    wrapper.instance().handleInputChange('Patrick', event)
    expect(wrapper.instance().handleInputChange).toHaveBeenCalled()
    expect(wrapper.state().firstname).toEqual('Patrick')
  })
})

describe('Last name', () => {
  const event = {
    currentTarget: {
      name: 'user[last_name]',
      value: 'Patrick',
      type: 'text'
    }
  }
  it('should render Last name Form Group', () => {
    const wrapper = mount(<SignupForm {...props} />)
    expect(wrapper.find('input#user_last_name').length).toEqual(1)
  })
  it('should set lastname state', () => {
    const wrapper = mount(<SignupForm {...props} />)
    jest.spyOn(wrapper.instance(), 'handleInputChange')
    wrapper.instance().handleInputChange('Star', event)
    expect(wrapper.instance().handleInputChange).toHaveBeenCalled()
    expect(wrapper.state().lastname).toEqual('Star')
  })
})

describe('Password', () => {
  const event = {
    currentTarget: {
      name: 'user[password]',
      value: 'gary1234',
      type: 'password'
    }
  }
  it('should render Password Form Group', () => {
    const wrapper = mount(<SignupForm {...props} />)
    expect(wrapper.find('input#user_password').length).toEqual(1)
  })
  it('should set password state', () => {
    const wrapper = mount(<SignupForm {...props} />)
    jest.spyOn(wrapper.instance(), 'handleInputChange')
    wrapper.instance().handleInputChange('gary1234', event)
    expect(wrapper.instance().handleInputChange).toHaveBeenCalled()
    expect(wrapper.state().password).toEqual('gary1234')
  })
})

describe('Password confirmation', () => {
  const event = {
    currentTarget: {
      name: 'user[password_confirmation]',
      value: 'gary1234',
      type: 'password'
    }
  }
  it('should render Password confirmation Form Group', () => {
    const wrapper = mount(<SignupForm {...props} />)
    expect(wrapper.find('input#user_password_confirmation').length).toEqual(1)
  })
  it('should set passwordConfirmation state', () => {
    const wrapper = mount(<SignupForm {...props} />)
    jest.spyOn(wrapper.instance(), 'handleInputChange')
    wrapper.instance().handleInputChange('gary1234', event)
    expect(wrapper.instance().handleInputChange).toHaveBeenCalled()
    expect(wrapper.state().passwordConfirmation).toEqual('gary1234')
  })
})
