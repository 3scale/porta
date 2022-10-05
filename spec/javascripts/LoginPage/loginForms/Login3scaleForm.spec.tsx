import { mount } from 'enzyme'
import { HiddenInputs } from 'LoginPage/loginForms/HiddenInputs'
import { Login3scaleForm } from 'LoginPage/loginForms/Login3scaleForm'

import type { FormEvent } from 'react'
import type { Props } from 'LoginPage/loginForms/Login3scaleForm'

const props: Props = {
  providerSessionsPath: 'sessions-path',
  session: { username: '' }
} as const

it('should render itself with right props', () => {
  const wrapper = mount(<Login3scaleForm {...props} />)
  expect(wrapper.find('form#new_session').exists()).toEqual(true)
  expect(wrapper.props().providerSessionsPath).toEqual('sessions-path')
})

it('should render HTML form markup', () => {
  const wrapper = mount(<Login3scaleForm {...props} />)
  expect(wrapper.find('input#session_username').exists()).toEqual(true)
  expect(wrapper.find('input#session_password').exists()).toEqual(true)
})

it('should render HiddenInputs component', () => {
  const wrapper = mount(<Login3scaleForm {...props} />)
  expect(wrapper.find(HiddenInputs).exists()).toEqual(true)
})

describe('username', () => {
  it('should set username and validation state to true', () => {
    const event = {
      currentTarget: {
        name: 'username',
        value: 'Bob',
        type: 'text'
      }
    } as unknown as FormEvent
    const wrapper = mount<Login3scaleForm>(<Login3scaleForm {...props} />)
    wrapper.find('input#session_username').props().onChange!(event)
    expect(wrapper.state('username')).toEqual('Bob')
    expect(wrapper.state().validation.username).toEqual(true)
  })

  it('should set validation username state to false when input value is missing', () => {
    const event = {
      currentTarget: {
        name: 'username',
        value: '',
        type: 'text'
      }
    } as unknown as FormEvent
    const wrapper = mount<Login3scaleForm>(<Login3scaleForm {...props} />)
    wrapper.find('input#session_username').props().onChange!(event)
    expect(wrapper.state().username).toEqual('')
    expect(wrapper.state().validation.username).toEqual(false)
  })

  it('should autofocus username input when username is not passed as param', () => {
    const wrapper = mount<Login3scaleForm>(<Login3scaleForm {...props} />)

    expect(wrapper.find('input#session_username').props().autoFocus).toBe(true)
    expect(wrapper.find('input#session_password').props().autoFocus).toBe(false)
  })
})

describe('password', () => {
  it('should set password and validation state to true', () => {
    const event = {
      currentTarget: {
        name: 'password',
        value: 'gary1234',
        type: 'password'
      }
    } as unknown as FormEvent
    const wrapper = mount<Login3scaleForm>(<Login3scaleForm {...props} />)
    wrapper.find('input#session_password').props().onChange!(event)
    expect(wrapper.state().password).toEqual('gary1234')
    expect(wrapper.state().validation.password).toEqual(true)
  })

  it('should set validation.password state to false when input value is missing', () => {
    const event = {
      currentTarget: {
        name: 'password',
        value: '',
        type: 'text'
      }
    } as unknown as FormEvent
    const wrapper = mount<Login3scaleForm>(<Login3scaleForm {...props} />)
    wrapper.find('input#session_password').props().onChange!(event)
    expect(wrapper.state().password).toEqual('')
    expect(wrapper.state().validation.password).toEqual(false)
  })

  it('should autofocus password input when username is passed as param', () => {
    const propsUsernameParams = { ...props, session: { username: 'bob' } } as const
    const wrapper = mount<Login3scaleForm>(<Login3scaleForm {...propsUsernameParams} />)
    expect(wrapper.find('input#session_password').props().autoFocus).toBe(true)
    expect(wrapper.find('input#session_username').props().autoFocus).toBe(false)
  })
})
