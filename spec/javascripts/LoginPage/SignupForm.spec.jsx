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
      required: true,
      name: 'user[username]',
      value: 'Sandy',
      type: 'text'
    }
  }
  it('should render Username Form Group', () => {
    const wrapper = mount(<SignupForm {...props} />)
    expect(wrapper.find('input#user_username').length).toEqual(1)
  })
  it('should set username and validation state to true', () => {
    const wrapper = mount(<SignupForm {...props} />)
    wrapper.find('input#user_username').props().onChange(event)
    expect(wrapper.state().username).toEqual('Sandy')
    expect(wrapper.state('validation').username).toEqual(true)
  })
  it('should set validation state to false when username is invalid', () => {
    const event = {
      currentTarget: {
        required: true,
        name: 'user[username]',
        value: '',
        type: 'text'
      }
    }
    const wrapper = mount(<SignupForm {...props} />)
    wrapper.find('input#user_username').props().onChange(event)
    expect(wrapper.state().username).toEqual('')
    expect(wrapper.state('validation').username).toEqual(false)
  })
})

describe('Email', () => {
  const event = {
    currentTarget: {
      required: true,
      name: 'user[email]',
      value: 'bob@sponge.com',
      type: 'email'
    }
  }
  it('should render Email Form Group', () => {
    const wrapper = mount(<SignupForm {...props} />)
    expect(wrapper.find('input#user_email').length).toEqual(1)
  })
  it('should set email and validation state to true', () => {
    const wrapper = mount(<SignupForm {...props} />)
    wrapper.find('input#user_email').props().onChange(event)
    expect(wrapper.state().email).toEqual('bob@sponge.com')
    expect(wrapper.state('validation').email).toEqual(true)
  })
  it('should set validation state to false when email is invalid', () => {
    const event = {
      currentTarget: {
        required: true,
        name: 'user[email]',
        value: '',
        type: 'email'
      }
    }
    const wrapper = mount(<SignupForm {...props} />)
    wrapper.find('input#user_email').props().onChange(event)
    expect(wrapper.state().email).toEqual('')
    expect(wrapper.state('validation').email).toEqual(false)
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
  it('should set firstname and validation state to true', () => {
    const wrapper = mount(<SignupForm {...props} />)
    wrapper.find('input#user_first_name').props().onChange(event)
    expect(wrapper.state().firstName).toEqual('Patrick')
    expect(wrapper.state('validation').firstName).toEqual(true)
  })
  it('should have validation state set to true even with no First name', () => {
    const event = {
      currentTarget: {
        name: 'user[first_name]',
        value: '',
        type: 'text'
      }
    }
    const wrapper = mount(<SignupForm {...props} />)
    wrapper.find('input#user_first_name').props().onChange(event)
    expect(wrapper.state().firstName).toEqual('')
    expect(wrapper.state('validation').firstName).toEqual(true)
  })
})

describe('Last name', () => {
  const event = {
    currentTarget: {
      name: 'user[last_name]',
      value: 'Star',
      type: 'text'
    }
  }
  it('should render Last name Form Group', () => {
    const wrapper = mount(<SignupForm {...props} />)
    expect(wrapper.find('input#user_last_name').length).toEqual(1)
  })
  it('should set lastname and validation state to true', () => {
    const wrapper = mount(<SignupForm {...props} />)
    wrapper.find('input#user_last_name').props().onChange(event)
    expect(wrapper.state().lastName).toEqual('Star')
    expect(wrapper.state('validation').lastName).toEqual(true)
  })
  it('should have validation state true even with no Last name', () => {
    const event = {
      currentTarget: {
        name: 'user[last_name]',
        value: '',
        type: 'text'
      }
    }
    const wrapper = mount(<SignupForm {...props} />)
    wrapper.find('input#user_first_name').props().onChange(event)
    expect(wrapper.state().lastName).toEqual('')
    expect(wrapper.state('validation').lastName).toEqual(true)
  })
})

describe('Password', () => {
  const event = {
    currentTarget: {
      required: true,
      name: 'user[password]',
      value: 'gary1234',
      type: 'password'
    }
  }
  it('should render Password Form Group', () => {
    const wrapper = mount(<SignupForm {...props} />)
    expect(wrapper.find('input#user_password').length).toEqual(1)
  })
  it('should set password and validation state to true', () => {
    const wrapper = mount(<SignupForm {...props} />)
    wrapper.find('input#user_password').props().onChange(event)
    expect(wrapper.state().password).toEqual('gary1234')
    expect(wrapper.state('validation').password).toEqual(true)
  })
  it('should set validation state to false when password is invalid', () => {
    const event = {
      currentTarget: {
        required: true,
        name: 'user[password]',
        value: '',
        type: 'password'
      }
    }
    const wrapper = mount(<SignupForm {...props} />)
    wrapper.find('input#user_password').props().onChange(event)
    expect(wrapper.state().password).toEqual('')
    expect(wrapper.state('validation').password).toEqual(false)
  })
})

describe('Password confirmation', () => {
  const event = {
    currentTarget: {
      required: true,
      name: 'user[password_confirmation]',
      value: 'gary1234',
      type: 'password'
    }
  }
  it('should render Password confirmation Form Group', () => {
    const wrapper = mount(<SignupForm {...props} />)
    expect(wrapper.find('input#user_password_confirmation').length).toEqual(1)
  })
  it('should set passwordConfirmation and validation state to true', () => {
    const wrapper = mount(<SignupForm {...props} />)
    wrapper.find('input#user_password_confirmation').props().onChange(event)
    expect(wrapper.state().passwordConfirmation).toEqual('gary1234')
    expect(wrapper.state('validation').passwordConfirmation).toEqual(true)
  })
  it('should set validation state to false when password confirmation is invalid', () => {
    const event = {
      currentTarget: {
        required: true,
        name: 'user[password_confirmation]',
        value: '',
        type: 'password'
      }
    }
    const wrapper = mount(<SignupForm {...props} />)
    wrapper.find('input#user_password_confirmation').props().onChange(event)
    expect(wrapper.state().passwordConfirmation).toEqual('')
    expect(wrapper.state('validation').passwordConfirmation).toEqual(false)
  })
})
