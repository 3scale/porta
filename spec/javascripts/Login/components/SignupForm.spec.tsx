import { mount } from 'enzyme'
import { act } from 'react-dom/test-utils'

import { SignupForm } from 'Login/components/SignupForm'
import { isSubmitDisabled } from 'utilities/test-utils'

import type { Props } from 'Login/components/SignupForm'
import type { FormEvent } from 'react'

const defaultProps: Props = {
  alerts: [],
  user: {
    email: 'bob@sponge.com',
    firstname: 'Bob',
    lastname: 'Sponge',
    username: 'bobsponge'
  },
  path: 'bikini-bottom'
}

const validPassword = 'superSecret1234#'

const mountWrapper = (props: Partial<Props> = {}) => mount(<SignupForm {...{ ...defaultProps, ...props }} />)

const fillPasswordFields = (wrapper: ReturnType<typeof mountWrapper>) => {
  act(() => {
    wrapper.find('input#user_password').props().onChange!({
      currentTarget: { required: true, name: 'user[password]', value: validPassword, type: 'password' }
    } as FormEvent<HTMLInputElement>)
  })

  act(() => {
    wrapper.find('input#user_password_confirmation').props().onChange!({
      currentTarget: { required: true, name: 'user[password_confirmation]', value: validPassword, type: 'password' }
    } as FormEvent<HTMLInputElement>)
  })
}

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists('#signup_form')).toEqual(true)
})

it('should render six Form Groups', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('.pf-c-form__group label').length).toEqual(6)
})

describe('validation', () => {
  let wrapper: ReturnType<typeof mountWrapper>

  beforeEach(() => {
    wrapper = mountWrapper()
    fillPasswordFields(wrapper)
  })

  it('should enable the button when all required fields are valid', () => {
    expect(isSubmitDisabled(wrapper)).toEqual(false)
  })

  it('should set username and validation state to true', () => {
    const event = {
      currentTarget: {
        required: true,
        name: 'user[username]',
        value: 'Sandy',
        type: 'text'
      }
    } as FormEvent<HTMLInputElement>

    act(() => { wrapper.find('input#user_username').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(false)
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

    act(() => { wrapper.find('input#user_email').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(false)
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

    act(() => { wrapper.find('input#user_email').props().onChange!(event) })
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

    act(() => { wrapper.find('input#user_first_name').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(false)
  })

  it('should have validation state set to true even with no First name', () => {
    const event = {
      currentTarget: {
        name: 'user[first_name]',
        value: '',
        type: 'text'
      }
    } as FormEvent<HTMLInputElement>

    act(() => { wrapper.find('input#user_first_name').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(false)
  })

  it('should set lastname and validation state to true', () => {
    const event = {
      currentTarget: {
        name: 'user[last_name]',
        value: 'Star',
        type: 'text'
      }
    } as FormEvent<HTMLInputElement>

    act(() => { wrapper.find('input#user_last_name').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(false)
  })

  it('should have validation state true even with no Last name', () => {
    const event = {
      currentTarget: {
        name: 'user[last_name]',
        value: '',
        type: 'text'
      }
    } as FormEvent<HTMLInputElement>

    act(() => { wrapper.find('input#user_last_name').props().onChange!(event) })
    expect(isSubmitDisabled(wrapper)).toEqual(false)
  })

  it('should set password and validation state to true', () => {
    const passwordEvent = {
      currentTarget: {
        required: true,
        name: 'user[password]',
        value: validPassword,
        type: 'password'
      }
    } as FormEvent<HTMLInputElement>

    const confirmationEvent = {
      currentTarget: {
        required: true,
        name: 'user[password_confirmation]',
        value: validPassword,
        type: 'password'
      }
    } as FormEvent<HTMLInputElement>

    act(() => { wrapper.find('input#user_password').props().onChange!(passwordEvent) })
    act(() => { wrapper.find('input#user_password_confirmation').props().onChange!(confirmationEvent) })
    expect(isSubmitDisabled(wrapper)).toEqual(false)
  })

  it('should set validation state to false when password is weak', () => {
    const passwordEvent = {
      currentTarget: {
        required: true,
        name: 'user[password]',
        value: 'gary1234',
        type: 'password'
      }
    } as FormEvent<HTMLInputElement>

    const confirmationEvent = {
      currentTarget: {
        required: true,
        name: 'user[password_confirmation]',
        value: 'gary1234',
        type: 'password'
      }
    } as FormEvent<HTMLInputElement>

    act(() => { wrapper.find('input#user_password').props().onChange!(passwordEvent) })
    act(() => { wrapper.find('input#user_password_confirmation').props().onChange!(confirmationEvent) })
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should set validation state to false when password is empty', () => {
    const passwordEvent = {
      currentTarget: {
        required: true,
        name: 'user[password]',
        value: '',
        type: 'password'
      }
    } as FormEvent<HTMLInputElement>

    const confirmationEvent = {
      currentTarget: {
        required: true,
        name: 'user[password_confirmation]',
        value: '',
        type: 'password'
      }
    } as FormEvent<HTMLInputElement>

    act(() => { wrapper.find('input#user_password').props().onChange!(passwordEvent) })
    act(() => { wrapper.find('input#user_password_confirmation').props().onChange!(confirmationEvent) })
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should set passwordConfirmation and validation state to true', () => {
    const passwordEvent = {
      currentTarget: {
        required: true,
        name: 'user[password]',
        value: validPassword,
        type: 'password'
      }
    } as FormEvent<HTMLInputElement>

    const confirmationEvent = {
      currentTarget: {
        required: true,
        name: 'user[password_confirmation]',
        value: validPassword,
        type: 'password'
      }
    } as FormEvent<HTMLInputElement>

    act(() => { wrapper.find('input#user_password').props().onChange!(passwordEvent) })
    act(() => { wrapper.find('input#user_password_confirmation').props().onChange!(confirmationEvent) })
    expect(isSubmitDisabled(wrapper)).toEqual(false)
  })

  it('should set validation state to false when password confirmation is empty', () => {
    const passwordEvent = {
      currentTarget: {
        required: true,
        name: 'user[password]',
        value: validPassword,
        type: 'password'
      }
    } as FormEvent<HTMLInputElement>

    const confirmationEvent = {
      currentTarget: {
        required: true,
        name: 'user[password_confirmation]',
        value: '',
        type: 'password'
      }
    } as FormEvent<HTMLInputElement>

    act(() => { wrapper.find('input#user_password').props().onChange!(passwordEvent) })
    act(() => { wrapper.find('input#user_password_confirmation').props().onChange!(confirmationEvent) })
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should set validation state to false when password and confirmation do not match', () => {
    const anotherValidPassword = 'anotherSecret1234#'

    const passwordEvent = {
      currentTarget: {
        required: true,
        name: 'user[password]',
        value: validPassword,
        type: 'password'
      }
    } as FormEvent<HTMLInputElement>

    const confirmationEvent = {
      currentTarget: {
        required: true,
        name: 'user[password_confirmation]',
        value: anotherValidPassword,
        type: 'password'
      }
    } as FormEvent<HTMLInputElement>

    act(() => { wrapper.find('input#user_password').props().onChange!(passwordEvent) })
    act(() => { wrapper.find('input#user_password_confirmation').props().onChange!(confirmationEvent) })
    expect(isSubmitDisabled(wrapper)).toEqual(true)
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
