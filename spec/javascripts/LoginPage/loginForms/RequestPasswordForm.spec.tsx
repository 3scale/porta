import { mount } from 'enzyme'
import { act } from 'react-dom/test-utils'

import { RequestPasswordForm } from 'Login/components/RequestPasswordForm'
import { isSubmitDisabled } from 'utilities/test-utils'

import type { FormEvent } from 'react'
import type { Props } from 'Login/components/RequestPasswordForm'

const defaultProps = {
  flashMessages: [],
  providerLoginPath: 'login-path',
  providerPasswordPath: 'password-path'
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
