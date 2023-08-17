import { mount } from 'enzyme'
import { act } from 'react-dom/test-utils'

import { LoginForm } from 'Login/components/LoginForm'
import { isSubmitDisabled, updateInput } from 'utilities/test-utils'

import type { FocusEvent } from 'react'
import type { Props } from 'Login/components/LoginForm'

const defaultProps: Props = {
  providerSessionsPath: 'sessions-path',
  session: { username: null }
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<LoginForm {...{ ...defaultProps, ...props }} />)

it('should set the correct form action', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('form.pf-c-form').props().action).toEqual(defaultProps.providerSessionsPath)
})

it('should validate username when losing focus or updating', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists('.pf-m-error')).toEqual(false)

  updateInput(wrapper, '', 'input#session_username')
  expect(wrapper.update().exists('.pf-m-error')).toEqual(false)

  act(() => { wrapper.find('input#session_password').props().onBlur!({} as unknown as FocusEvent<HTMLInputElement>) })
  expect(wrapper.update().exists('.pf-m-error')).toEqual(true)

  updateInput(wrapper, 'pepe', 'input#session_username')
  expect(wrapper.update().exists('.pf-m-error')).toEqual(true)
})

it('should validate password when losing focus or updating', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists('.pf-m-error')).toEqual(false)

  updateInput(wrapper, '', 'input#session_password')
  expect(wrapper.update().exists('.pf-m-error')).toEqual(false)

  act(() => { wrapper.find('input#session_password').props().onBlur!({} as unknown as FocusEvent<HTMLInputElement>) })
  expect(wrapper.update().exists('.pf-m-error')).toEqual(true)

  updateInput(wrapper, '******', 'input#session_password')
  expect(wrapper.update().exists('.pf-m-error')).toEqual(false)
})

it('should disable the sign in button unless fields are filled', () => {
  const wrapper = mountWrapper()
  expect(isSubmitDisabled(wrapper)).toEqual(true)

  updateInput(wrapper, 'p', 'input#session_username')
  updateInput(wrapper, '', 'input#session_password')
  expect(isSubmitDisabled(wrapper)).toEqual(true)

  updateInput(wrapper, '', 'input#session_username')
  updateInput(wrapper, 'p', 'input#session_password')
  expect(isSubmitDisabled(wrapper)).toEqual(true)

  updateInput(wrapper, 'p', 'input#session_username')
  updateInput(wrapper, 'p', 'input#session_password')
  expect(isSubmitDisabled(wrapper)).toEqual(false)
})

describe('when on the first attempt', () => {
  const props = { session: { username: null } }

  it('should render the fields empty and no error by default', () => {
    const wrapper = mountWrapper(props)

    expect(wrapper.exists('.pf-m-error')).toEqual(false)
    expect(wrapper.find('input[name="username"]').props().value).toEqual('')
    expect(wrapper.find('input[name="password"]').props().value).toEqual('')
  })

  it('should disable the sign in button', () => {
    const wrapper = mountWrapper(props)
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should autofocus username', () => {
    const wrapper = mountWrapper()

    expect(wrapper.find('input#session_username').props().autoFocus).toEqual(true)
    expect(wrapper.find('input#session_password').props().autoFocus).toEqual(false)
  })
})

describe('when the last attempt failed', () => {
  const props = { session: { username: 'random_user' } }

  it('should disable the sign in button', () => {
    const wrapper = mountWrapper(props)
    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should autofocus username', () => {
    const wrapper = mountWrapper(props)

    expect(wrapper.find('input#session_username').props().autoFocus).toEqual(false)
    expect(wrapper.find('input#session_password').props().autoFocus).toEqual(true)
  })

  it('should enable the sign in button when typing a password', () => {
    const wrapper = mountWrapper(props)

    updateInput(wrapper, 'p', 'input#session_password')
    expect(isSubmitDisabled(wrapper)).toEqual(false)
  })
})
