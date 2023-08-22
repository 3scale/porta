import { mount } from 'enzyme'
import { act } from 'react-dom/test-utils'

import { SignupForm } from 'Login/components/SignupForm'
import { isSubmitDisabled } from 'utilities/test-utils'

import type { Props } from 'Login/components/SignupForm'
import type { FormEvent } from 'react'

const defaultProps: Props = {
  user: {
    email: 'bob@sponge.com',
    firstname: 'Bob',
    lastname: 'Sponge',
    username: 'bobsponge',
    errors: []
  },
  path: 'bikini-bottom'
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<SignupForm {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists('#signup_form')).toEqual(true)
})

it('should render six Form Groups', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('.pf-c-form__group label').length).toEqual(6)
})

describe('validation', () => {
  it('should set username and validation state to true', () => {
    const event = {
      currentTarget: {
        required: true,
        name: 'user[username]',
        value: 'Sandy',
        type: 'text'
      }
    } as FormEvent<HTMLInputElement>

    const wrapper = mountWrapper()
    act(() => { wrapper.find('input#user_username').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should set validation state to false when username is invalid', () => {
    const event = {
      currentTarget: {
        required: true,
        name: 'user[username]',
        value: '',
        type: 'text'
      }
    } as FormEvent<HTMLInputElement>

    const wrapper = mountWrapper()
    act(() => { wrapper.find('input#user_username').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should set email and validation state to true', () => {
    const event = {
      currentTarget: {
        required: true,
        name: 'user[email]',
        value: 'bob@sponge.com',
        type: 'email'
      }
    } as FormEvent<HTMLInputElement>

    const wrapper = mountWrapper()
    act(() => { wrapper.find('input#user_email').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should set validation state to false when email is invalid', () => {
    const event = {
      currentTarget: {
        required: true,
        name: 'user[email]',
        value: '',
        type: 'email'
      }
    } as FormEvent<HTMLInputElement>

    const wrapper = mountWrapper()
    act(() => {  wrapper.find('input#user_email').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should set firstname and validation state to true', () => {
    const event = {
      currentTarget: {
        name: 'user[first_name]',
        value: 'Patrick',
        type: 'text'
      }
    } as FormEvent<HTMLInputElement>

    const wrapper = mountWrapper()
    act(() => { wrapper.find('input#user_first_name').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should have validation state set to true even with no First name', () => {
    const event = {
      currentTarget: {
        name: 'user[first_name]',
        value: '',
        type: 'text'
      }
    } as FormEvent<HTMLInputElement>

    const wrapper = mountWrapper()
    act(() => { wrapper.find('input#user_first_name').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should set lastname and validation state to true', () => {
    const event = {
      currentTarget: {
        name: 'user[last_name]',
        value: 'Star',
        type: 'text'
      }
    } as FormEvent<HTMLInputElement>

    const wrapper = mountWrapper()
    act(() => { wrapper.find('input#user_last_name').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should have validation state true even with no Last name', () => {
    const event = {
      currentTarget: {
        name: 'user[last_name]',
        value: '',
        type: 'text'
      }
    } as FormEvent<HTMLInputElement>

    const wrapper = mountWrapper()
    act(() => { wrapper.find('input#user_first_name').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should set password and validation state to true', () => {
    const event = {
      currentTarget: {
        required: true,
        name: 'user[password]',
        value: 'gary1234',
        type: 'password'
      }
    } as FormEvent<HTMLInputElement>

    const wrapper = mountWrapper()
    act(() => { wrapper.find('input#user_password').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should set validation state to false when password is invalid', () => {
    const event = {
      currentTarget: {
        required: true,
        name: 'user[password]',
        value: '',
        type: 'password'
      }
    } as FormEvent<HTMLInputElement>

    const wrapper = mountWrapper()
    act(() => { wrapper.find('input#user_password').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should set passwordConfirmation and validation state to true', () => {
    const event = {
      currentTarget: {
        required: true,
        name: 'user[password_confirmation]',
        value: 'gary1234',
        type: 'password'
      }
    } as FormEvent<HTMLInputElement>

    const wrapper = mountWrapper()
    act(() => { wrapper.find('input#user_password_confirmation').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should set validation state to false when password confirmation is invalid', () => {
    const event = {
      currentTarget: {
        required: true,
        name: 'user[password_confirmation]',
        value: '',
        type: 'password'
      }
    } as FormEvent<HTMLInputElement>

    const wrapper = mountWrapper()
    act(() => { wrapper.find('input#user_password_confirmation').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should enable the button after filling up required fields', () => {
    const wrapper = mountWrapper()

    act(() => {
      wrapper.find('input#user_username').props().onChange!({
        currentTarget: {
          required: true,
          name: 'user[username]',
          value: 'Sandy',
          type: 'text'
        }
      } as FormEvent<HTMLInputElement>)
    })
    expect(isSubmitDisabled(wrapper)).toEqual(true)

    act(() => {
      wrapper.find('input#user_email').props().onChange!({
        currentTarget: {
          required: true,
          name: 'user[email]',
          value: 'bob@sponge.com',
          type: 'email'
        }
      } as FormEvent<HTMLInputElement>)
    })
    expect(isSubmitDisabled(wrapper)).toEqual(true)

    act(() => {
      wrapper.find('input#user_first_name').props().onChange!({
        currentTarget: {
          name: 'user[first_name]',
          value: '',
          type: 'text'
        }
      } as FormEvent<HTMLInputElement>)
    })
    expect(isSubmitDisabled(wrapper)).toEqual(true)

    act(() => {
      wrapper.find('input#user_first_name').props().onChange!({
        currentTarget: {
          name: 'user[last_name]',
          value: '',
          type: 'text'
        }
      } as FormEvent<HTMLInputElement>)
    })
    expect(isSubmitDisabled(wrapper)).toEqual(true)

    act(() => {
      wrapper.find('input#user_password').props().onChange!({
        currentTarget: {
          required: true,
          name: 'user[password]',
          value: 'gary1234',
          type: 'password'
        }
      } as FormEvent<HTMLInputElement>)
    })
    expect(isSubmitDisabled(wrapper)).toEqual(true)

    act(() => {
      wrapper.find('input#user_password_confirmation').props().onChange!({
        currentTarget: {
          required: true,
          name: 'user[password_confirmation]',
          value: 'gary1234',
          type: 'password'
        }
      } as FormEvent<HTMLInputElement>)
    })
    expect(isSubmitDisabled(wrapper)).toEqual(false)
  })
})

describe('Username', () => {
  it('should render Username Form Group', () => {
    const wrapper = mountWrapper()
    expect(wrapper.find('input#user_username').length).toEqual(1)
  })
})

describe('Email', () => {
  it('should render Email Form Group', () => {
    const wrapper = mountWrapper()
    expect(wrapper.find('input#user_email').length).toEqual(1)
  })
})

describe('First name', () => {
  it('should render First name Form Group', () => {
    const wrapper = mountWrapper()
    expect(wrapper.find('input#user_first_name').length).toEqual(1)
  })
})

describe('Last name', () => {
  it('should render Last name Form Group', () => {
    const wrapper = mountWrapper()
    expect(wrapper.find('input#user_last_name').length).toEqual(1)
  })
})

describe('Password', () => {
  it('should render Password Form Group', () => {
    const wrapper = mountWrapper()
    expect(wrapper.find('input#user_password').length).toEqual(1)
  })
})

describe('Password confirmation', () => {
  it('should render Password confirmation Form Group', () => {
    const wrapper = mountWrapper()
    expect(wrapper.find('input#user_password_confirmation').length).toEqual(1)
  })
})
