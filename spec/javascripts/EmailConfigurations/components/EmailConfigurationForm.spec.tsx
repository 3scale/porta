import React from 'react'
import { mount, render } from 'enzyme'

import { EmailConfigurationForm } from 'EmailConfigurations/components/EmailConfigurationForm'
import { isSubmitDisabled, updateInput } from 'utilities/test-utils'

const defaultProps = {
  emailConfiguration: {
    email: '',
    userName: '',
    password: ''
  },
  errors: undefined,
  isUpdate: undefined,
  url: 'p/admin/email_configurations'
} as const

const mountWrapper = (props) => mount(<EmailConfigurationForm {...{ ...defaultProps, ...props }} />)
const renderWrapper = (props: undefined) => render(<EmailConfigurationForm {...{ ...defaultProps, ...props }}/>)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should render all fields', () => {
  const inputs = [
    'email_configuration_email',
    'email_configuration_user_name',
    'email_configuration_password',
    'email_configuration_password_repeat'
  ]

  const html = renderWrapper().find('.pf-c-form__group').toString()

  inputs.forEach(name => expect(html).toMatch(name))
})

describe('when the server returns some errors', () => {
  const errors = {
    email: ['Too long'],
    user_name: ['Too short'],
    password: ['Too silly']
  } as const

  it('should render them properly', () => {
    const wrapper = mountWrapper({ errors })

    const emailError = wrapper.find('#email_configuration_email ~ .pf-m-error')
    expect(emailError.text()).toEqual(errors.email.toString())

    const passwordError = wrapper.find('#email_configuration_password ~ .pf-m-error')
    expect(passwordError.text()).toEqual(errors.password.toString())

    const userNameError = wrapper.find('#email_configuration_user_name ~ .pf-m-error')
    expect(userNameError.text()).toEqual(errors.user_name.toString())
  })
})

describe('when some fields are returned by the server', () => {
  const emailConfiguration = {
    id: 0,
    email: 'hello@ollivanders.co.uk',
    userName: 'ollivanders_wands',
    password: '123456'
  } as const

  it('should populate the fields with the values', () => {
    const wrapper = mountWrapper({ emailConfiguration })

    expect(wrapper.find('input#email_configuration_email').prop('value')).toEqual(emailConfiguration.email)
    expect(wrapper.find('input#email_configuration_user_name').prop('value')).toEqual(emailConfiguration.userName)
    expect(wrapper.find('input#email_configuration_password').prop('value')).toEqual(emailConfiguration.password)
  })
})

describe('when it is new page form', () => {
  it('should enable submit the form only when password is confirmed', () => {
    const wrapper = mountWrapper()
    expect(isSubmitDisabled(wrapper)).toBe(true)

    updateInput(wrapper, '$DragonHeartsstring1909', 'input[name="email_configuration[password]"]')
    expect(isSubmitDisabled(wrapper)).toEqual(true)

    updateInput(wrapper, '$DragonHeartsstring1909', 'input#email_configuration_password_repeat')
    expect(isSubmitDisabled(wrapper)).toEqual(false)
  })
})

describe('when it is edit page form', () => {
  const emailConfiguration = {
    email: 'hello@ollivanders.co.uk',
    userName: 'ollivanders_wands',
    password: '$DragonHeartsstring1909'
  } as const
  const props = { isUpdate: true, emailConfiguration } as const

  it('should disable the button as long as no field is changed', () => {
    const wrapper = mountWrapper(props)
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should enable the button when email changes', () => {
    const wrapper = mountWrapper(props)

    updateInput(wrapper, 'hello@ollivanders.io', 'input[name="email_configuration[email]"]')
    expect(isSubmitDisabled(wrapper)).toEqual(false)

    updateInput(wrapper, 'hello@ollivanders.co.uk', 'input[name="email_configuration[email]"]')
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should enable the button when username changes', () => {
    const wrapper = mountWrapper(props)

    updateInput(wrapper, 'wandcraft_ollivanders', 'input[name="email_configuration[user_name]"]')
    expect(isSubmitDisabled(wrapper)).toEqual(false)

    updateInput(wrapper, 'ollivanders_wands', 'input[name="email_configuration[user_name]"]')
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should disable the button if password updated but not confirmed', () => {
    const wrapper = mountWrapper(props)

    updateInput(wrapper, 'new_password', 'input[name="email_configuration[password]"]')
    expect(isSubmitDisabled(wrapper)).toEqual(true)

    updateInput(wrapper, 'new_password', 'input#email_configuration_password_repeat')
    expect(isSubmitDisabled(wrapper)).toEqual(false)
  })

  it('should be able to delete it', () => {
    const wrapper = mountWrapper(props)

    const deleteButton = wrapper.find('button.pf-m-danger[type="submit"]')
    expect(deleteButton.prop('disabled')).toBe(false)
  })
})
