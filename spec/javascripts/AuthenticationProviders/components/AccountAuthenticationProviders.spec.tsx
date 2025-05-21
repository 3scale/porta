import { shallow, mount } from 'enzyme'
import { Modal } from '@patternfly/react-core'
import { act } from 'react-dom/test-utils'

import * as ajax from 'utilities/ajax'
import * as toast from 'utilities/toast'
import { AccountAuthenticationProviders } from 'AuthenticationProviders/components/AccountAuthenticationProviders'
import { mockLocation, waitForPromises } from 'utilities/test-utils'
import { EnforceSSOSwitch } from 'AuthenticationProviders/components/EnforceSSOSwitch'
import { AuthenticationProvidersTable } from 'AuthenticationProviders/components/AuthenticationProvidersTable'
import { AuthenticationProvidersEmptyState } from 'AuthenticationProviders/components/AuthenticationProvidersEmptyState'

import type { Props } from 'AuthenticationProviders/components/AccountAuthenticationProviders'

const ajaxJSON = jest.spyOn(ajax, 'ajaxJSON')
const toastSpy = jest.spyOn(toast, 'toast')

const defaultProps: Props = {
  showToggle: false,
  table: {
    count: 0,
    items: [],
    deleteTemplateHref: '',
    newHref: ''
  },
  ssoEnabled: false,
  toggleDisabled: false,
  ssoPath: '/sso'
}

const shallowWrapper = (props: Partial<Props> = {}) => shallow(<AccountAuthenticationProviders {...{ ...defaultProps, ...props }} />)
const mountWrapper = (props: Partial<Props> = {}) => mount(<AccountAuthenticationProviders {...{ ...defaultProps, ...props }} />)

beforeEach(() => {
  jest.resetAllMocks()
  mockLocation('https://example.com')
})

afterAll(() => {
  jest.restoreAllMocks()
})

describe('when SSO toggle is hidden', () => {
  const props = { showToggle: false }

  it('should render empty state', () => {
    const wrapper = shallowWrapper(props)
    expect(wrapper.exists(EnforceSSOSwitch)).toEqual(false)
    expect(wrapper.exists(AuthenticationProvidersEmptyState)).toEqual(true)
  })
})

describe('when SSO toggle is visible', () => {
  const props = { showToggle: true, table: { ...defaultProps.table, count: 1 } }

  it('should render both a switch and a table', () => {
    const wrapper = shallowWrapper(props)
    expect(wrapper.exists(EnforceSSOSwitch)).toEqual(true)
    expect(wrapper.exists(AuthenticationProvidersTable)).toEqual(true)
  })

  it('should confirm before disabling password-based authentication', async () => {
    const payload = { type: 'success', message: 'Enabled', ok: true }
    ajaxJSON.mockResolvedValueOnce({ json: () => Promise.resolve(payload) } as Response)

    const wrapper = mountWrapper({ ...props, ssoEnabled: false })
    expect(wrapper.find(EnforceSSOSwitch).props().isChecked).toEqual(false)
    expect(wrapper.exists(Modal)).toEqual(false)

    act(() => { wrapper.find(EnforceSSOSwitch).props().onChange(true) })

    await waitForPromises(wrapper)
    expect(wrapper.exists(Modal)).toEqual(true)

    // @ts-expect-error -- We don't need mouse event
    act(() => { wrapper.find('Modal button.pf-m-primary').props().onClick() })

    await waitForPromises(wrapper)
    expect(wrapper.find(EnforceSSOSwitch).props().isChecked).toEqual(true)
    expect(toastSpy).toHaveBeenCalledWith(payload.message, 'success')
  })

  it('should confirm before enabling password-based authentication', async () => {
    const payload = { type: 'success', message: 'Disabled', ok: true }
    ajaxJSON.mockResolvedValueOnce({ json: () => Promise.resolve(payload) } as Response)

    const wrapper = mountWrapper({ ...props, ssoEnabled: true })
    expect(wrapper.find(EnforceSSOSwitch).props().isChecked).toEqual(true)
    expect(wrapper.exists(Modal)).toEqual(false)

    act(() => { wrapper.find(EnforceSSOSwitch).props().onChange(false) })

    await waitForPromises(wrapper)
    expect(wrapper.exists(Modal)).toEqual(true)

    // @ts-expect-error -- We don't need mouse event
    act(() => { wrapper.find('button.pf-m-primary').props().onClick() })

    await waitForPromises(wrapper)
    expect(wrapper.find(EnforceSSOSwitch).props().isChecked).toEqual(false)
    expect(toastSpy).toHaveBeenCalledWith(payload.message, 'success')
  })

  it('should not break when enabling fails', async () => {
    const payload = { type: 'danger', message: 'Cannot enable', ok: false }
    ajaxJSON.mockResolvedValueOnce({ json: () => Promise.resolve(payload) } as Response)

    const wrapper = mountWrapper({ ...props, ssoEnabled: false })
    expect(wrapper.find(EnforceSSOSwitch).props().isChecked).toEqual(false)
    expect(wrapper.exists(Modal)).toEqual(false)

    act(() => { wrapper.find(EnforceSSOSwitch).props().onChange(true) })

    await waitForPromises(wrapper)
    expect(wrapper.exists(Modal)).toEqual(true)

    // @ts-expect-error -- We don't need mouse event
    act(() => { wrapper.find('Modal button.pf-m-primary').props().onClick() })

    await waitForPromises(wrapper)
    expect(wrapper.find(EnforceSSOSwitch).props().isChecked).toEqual(false)
    expect(toastSpy).toHaveBeenCalledWith(payload.message, 'danger')
  })

  it('should not break when disabling fails', async () => {
    const payload = { type: 'danger', message: 'Cannot disable', ok: false }
    ajaxJSON.mockResolvedValueOnce({ json: () => Promise.resolve(payload) } as Response)

    const wrapper = mountWrapper({ ...props, ssoEnabled: true })
    expect(wrapper.find(EnforceSSOSwitch).props().isChecked).toEqual(true)
    expect(wrapper.exists(Modal)).toEqual(false)

    act(() => { wrapper.find(EnforceSSOSwitch).props().onChange(false) })

    await waitForPromises(wrapper)
    expect(wrapper.exists(Modal)).toEqual(true)

    // @ts-expect-error -- We don't need mouse event
    act(() => { wrapper.find('Modal button.pf-m-primary').props().onClick() })

    await waitForPromises(wrapper)
    expect(wrapper.find(EnforceSSOSwitch).props().isChecked).toEqual(true)
    expect(toastSpy).toHaveBeenCalledWith(payload.message, 'danger')
  })
})
