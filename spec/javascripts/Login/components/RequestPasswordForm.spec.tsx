import { mount } from 'enzyme'
import { act } from 'react-dom/test-utils'

import { RequestPasswordForm } from 'Login/components/RequestPasswordForm'
import { isSubmitDisabled } from 'utilities/test-utils'

import type { FormEvent } from 'react'
import type { Props } from 'Login/components/RequestPasswordForm'

const defaultProps = {
  alerts: [],
  providerLoginPath: 'login-path',
  providerPasswordPath: 'password-path',
  recaptcha: {
    enabled: false,
    siteKey: '',
    action: ''
  }
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<RequestPasswordForm {...{ ...defaultProps, ...props }} />)

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
  act(() => { wrapper.find('input#email').props().onChange!(event) })
  expect(isSubmitDisabled(wrapper)).toEqual(false)
})

it('should set validation state to false when email is invalid', () => {
  const event = {
    currentTarget: {
      value: 'bobspongecom',
      type: 'email'
    }
  } as FormEvent<HTMLInputElement>

  const wrapper = mountWrapper()
  act(() => { wrapper.find('input#email').props().onChange!(event) })
  expect(isSubmitDisabled(wrapper)).toEqual(true)
})

it('should not render reCAPTCHA when disabled', () => {
  const wrapper = mountWrapper({ recaptcha: { enabled: false, siteKey: 'key', action: 'provider/passwords' } })
  expect(wrapper.exists('input.g-recaptcha')).toEqual(false)
})

it('should render reCAPTCHA when enabled', () => {
  const wrapper = mountWrapper({ recaptcha: { enabled: true, siteKey: 'key', action: 'provider/passwords' } })
  expect(wrapper.exists('input.g-recaptcha')).toEqual(true)
})
