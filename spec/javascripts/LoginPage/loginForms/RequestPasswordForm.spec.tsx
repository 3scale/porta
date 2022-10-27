import { mount } from 'enzyme'

import { RequestPasswordForm } from 'LoginPage/loginForms/RequestPasswordForm'

import type { FormEvent } from 'react'
import type { Props } from 'LoginPage/loginForms/RequestPasswordForm'

const defaultProps = {
  flashMessages: [],
  providerLoginPath: 'login-path',
  providerPasswordPath: 'password-path'
}

const mountWrapper = (props: Partial<Props> = {}) => mount<RequestPasswordForm>(<RequestPasswordForm {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper).toMatchSnapshot()
})

it('should set email and validation state to true', () => {
  const event = {
    currentTarget: {
      value: 'bob@sponge.com',
      type: 'email'
    }
  } as FormEvent<HTMLInputElement>

  const wrapper = mountWrapper()
  wrapper.find('input#email').props().onChange!(event)
  expect(wrapper.state().email).toEqual('bob@sponge.com')
  expect(wrapper.state().validation.email).toEqual(true)
})

it('should set validation state to false when email is invalid', () => {
  const event = {
    currentTarget: {
      value: 'bobspongecom',
      type: 'email'
    }
  } as FormEvent<HTMLInputElement>

  const wrapper = mountWrapper()
  wrapper.find('input#email').props().onChange!(event)
  expect(wrapper.state().email).toEqual('bobspongecom')
  expect(wrapper.state().validation.email).toEqual(false)
})
