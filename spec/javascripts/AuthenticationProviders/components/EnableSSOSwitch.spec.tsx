import { mount } from 'enzyme'

import { EnforceSSOSwitch } from 'AuthenticationProviders/components/EnforceSSOSwitch'

import type { FormEvent } from 'react'
import type { Props } from 'AuthenticationProviders/components/EnforceSSOSwitch'

const defaultProps = {
  onChange: jest.fn(),
  isChecked: false,
  isDisabled: false,
  isLoading: false
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<EnforceSSOSwitch {...{ ...defaultProps, ...props }} />)

beforeEach(() => {
  jest.resetAllMocks()
})

afterAll(() => {
  jest.restoreAllMocks()
})

it('should not render a spinner by default', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists('.pf-c-spinner')).toEqual(false)
})

it('should not be checked by default', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('input[name="settings[enforce_sso]"]').prop('checked')).toEqual(false)
})

it('should be enabled by default', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('input[name="settings[enforce_sso]"]').prop('disabled')).toEqual(false)
})

describe('when the switch is disabled', () => {
  const props = { isDisabled: true }

  it('should not be clickable', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.find('input[name="settings[enforce_sso]"]').prop('disabled')).toEqual(true)
  })

  it('should have a text', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.find('.pf-c-alert').text()).toMatch('To disable password-based authentication')
  })
})

describe('when password-based authentication is not disabled', () => {
  const props = { isChecked: false, isDisabled: false }

  it('should not have a text', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.find('input[name="settings[enforce_sso]"]').prop('checked')).toEqual(false)
    expect(wrapper.exists('.pf-c-alert')).toEqual(false)
  })

  it('should be clickable', () => {
    const wrapper = mountWrapper(props)
    wrapper.find('input').props().onChange!({ target: { checked: true } } as unknown as FormEvent)
    expect(defaultProps.onChange).toHaveBeenCalledTimes(1)
    expect(defaultProps.onChange).toHaveBeenCalledWith(true, expect.anything())
  })
})

describe('when password-based authentication is disabled', () => {
  const props = { isChecked: true, isDisabled: false }

  it('should have a text', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.find('input[name="settings[enforce_sso]"]').prop('checked')).toEqual(true)
    expect(wrapper.find('.pf-c-alert').text()).toMatch('In order to edit active Single Sign-On')
  })

  it('should be clickable', () => {
    const wrapper = mountWrapper(props)
    wrapper.find('input').props().onChange!({ target: { checked: false } } as unknown as FormEvent)
    expect(defaultProps.onChange).toHaveBeenCalledTimes(1)
    expect(defaultProps.onChange).toHaveBeenCalledWith(false, expect.anything())
  })
})

describe('when loading', () => {
  const props = { isLoading: true, isDisabled: false }

  it('should be disabled', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.find('input[name="settings[enforce_sso]"]').prop('disabled')).toEqual(true)
  })

  it('should render a spinner', () => {
    const wrapper = mountWrapper(props)
    expect(wrapper.exists('.pf-c-spinner')).toEqual(true)
  })
})
