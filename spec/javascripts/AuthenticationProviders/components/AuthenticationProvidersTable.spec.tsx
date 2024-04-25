import { mount } from 'enzyme'

import * as ajax from 'utilities/ajax'
import * as flash from 'utilities/flash'
import { AuthenticationProvidersTable } from 'AuthenticationProviders/components/AuthenticationProvidersTable'
import { mockLocation, waitForPromises } from 'utilities/test-utils'

import type { Props } from 'AuthenticationProviders/components/AuthenticationProvidersTable'

const ajaxJSON = jest.spyOn(ajax, 'ajaxJSON')
const notice = jest.spyOn(flash, 'notice')
const error = jest.spyOn(flash, 'error')

const defaultProps = {
  count: 0,
  deleteTemplateHref: '/delete/:id',
  items: [{
    id: 123,
    createdOn: '6 Mar',
    name: 'Red Hat SSO',
    editPath: 'http://example.com/123/edit',
    path: '/123',
    published: false,
    state: 'Hidden',
    users: 0
  }],
  newHref: '/new'
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<AuthenticationProvidersTable {...{ ...defaultProps, ...props }} />)

beforeEach(() => {
  jest.resetAllMocks()
  mockLocation('https://example.com')
})

afterAll(() => {
  jest.restoreAllMocks()
})

it('should be able to delete an authentication provider', async () => {
  const payload = { redirect: '/authentication_providers' }
  ajaxJSON.mockResolvedValueOnce({ json: () => Promise.resolve(payload) } as Response)

  const wrapper = mountWrapper()
  wrapper.find('tr button.pf-c-dropdown__toggle').simulate('click')
  wrapper.find('tr button.pf-c-dropdown__menu-item[data-ouia-component-id="delete"]').simulate('click')

  wrapper.update()
    .find('Modal button.pf-m-danger').simulate('click')

  await waitForPromises(wrapper)
  expect(window.location.replace).toHaveBeenCalledWith('/authentication_providers')
})

it('should handle deletion errors gracefully', async () => {
  const payload = { redirect: undefined, error: 'Something went wrong' }
  ajaxJSON.mockResolvedValueOnce({ json: () => Promise.resolve(payload) } as Response)

  const wrapper = mountWrapper()
  wrapper.find('tr button.pf-c-dropdown__toggle').simulate('click')
  wrapper.find('tr button.pf-c-dropdown__menu-item[data-ouia-component-id="delete"]').simulate('click')

  wrapper.update()
    .find('Modal button.pf-m-danger').simulate('click')

  await waitForPromises(wrapper)
  expect(error).toHaveBeenCalledWith(payload.error)
  expect(notice).not.toHaveBeenCalled()
})

it('should be able to edit an authentication provider', () => {
  const target = 0

  const wrapper = mountWrapper()
  wrapper.find('tr button.pf-c-dropdown__toggle').at(target).simulate('click')
  wrapper.find('tr button.pf-c-dropdown__menu-item[data-ouia-component-id="edit"]').simulate('click')

  expect(window.location.href).toEqual(defaultProps.items[target].editPath)
})
