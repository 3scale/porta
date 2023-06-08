import { mount } from 'enzyme'
import { act } from 'react-dom/test-utils'

import { HiddenInputs } from 'Login/components/HiddenInputs'
import { Login3scaleForm } from 'Login/components/Login3scaleForm'
import { isSubmitDisabled } from 'utilities/test-utils'

import type { FormEvent } from 'react'
import type { Props } from 'Login/components/Login3scaleForm'

const props: Props = {
  providerSessionsPath: 'sessions-path',
  session: { username: '' }
} as const

it('should render itself with right props', () => {
  const wrapper = mount(<Login3scaleForm {...props} />)
  expect(wrapper.exists('form#new_session')).toEqual(true)
  expect(wrapper.props().providerSessionsPath).toEqual('sessions-path')
})

it('should render HTML form markup', () => {
  const wrapper = mount(<Login3scaleForm {...props} />)
  expect(wrapper.exists('input#session_username')).toEqual(true)
  expect(wrapper.exists('input#session_password')).toEqual(true)
})

it('should render HiddenInputs component', () => {
  const wrapper = mount(<Login3scaleForm {...props} />)
  expect(wrapper.exists(HiddenInputs)).toEqual(true)
})

describe('form validation', () => {
  it('should enable button if fields are filled', () => {
    const wrapper = mount(<Login3scaleForm {...props} />)
    expect(isSubmitDisabled(wrapper)).toEqual(true)

    act(() => {
      wrapper.find('input#session_username').props().onChange!({
        currentTarget: {
          name: 'username',
          value: 'Bob',
          type: 'text'
        }
      } as unknown as FormEvent)
    })

    act(() => {
      wrapper.find('input#session_password').props().onChange!({
        currentTarget: {
          name: 'password',
          value: 'gary1234',
          type: 'password'
        }
      } as unknown as FormEvent)
    })

    expect(isSubmitDisabled(wrapper)).toEqual(false)
  })

  it('should disable button if username is missing', () => {
    const wrapper = mount(<Login3scaleForm {...props} />)

    act(() => {
      wrapper.find('input#session_username').props().onChange!({
        currentTarget: {
          name: 'username',
          value: '',
          type: 'text'
        }
      } as unknown as FormEvent)
      wrapper.find('input#session_password').props().onChange!({
        currentTarget: {
          name: 'password',
          value: 'gary1234',
          type: 'password'
        }
      } as unknown as FormEvent)
    })

    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

  it('should disable button if password is missing', () => {
    const wrapper = mount(<Login3scaleForm {...props} />)

    act(() => {
      wrapper.find('input#session_username').props().onChange!({
        currentTarget: {
          name: 'username',
          value: '',
          type: 'text'
        }
      } as unknown as FormEvent)
      wrapper.find('input#session_password').props().onChange!({
        currentTarget: {
          name: 'password',
          value: '',
          type: 'password'
        }
      } as unknown as FormEvent)
    })

    expect(isSubmitDisabled(wrapper)).toEqual(true)
  })

})

describe('username', () => {
  it('should autofocus username input when username is not passed as param', () => {
    const wrapper = mount(<Login3scaleForm {...props} />)

    expect(wrapper.find('input#session_username').props().autoFocus).toEqual(true)
    expect(wrapper.find('input#session_password').props().autoFocus).toEqual(false)
  })
})

describe('password', () => {
  it('should autofocus password input when username is passed as param', () => {
    const propsUsernameParams = { ...props, session: { username: 'bob' } } as const
    const wrapper = mount(<Login3scaleForm {...propsUsernameParams} />)
    expect(wrapper.find('input#session_password').props().autoFocus).toEqual(true)
    expect(wrapper.find('input#session_username').props().autoFocus).toEqual(false)
  })
})
