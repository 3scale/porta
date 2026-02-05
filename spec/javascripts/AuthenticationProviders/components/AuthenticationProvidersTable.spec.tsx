import { mount } from 'enzyme'

import * as ajax from 'utilities/ajax'
import { toast } from 'utilities/toast'
import * as navigation from 'utilities/navigation'
import { AuthenticationProvidersTable } from 'AuthenticationProviders/components/AuthenticationProvidersTable'
import { waitForPromises } from 'utilities/test-utils'

import type { Props } from 'AuthenticationProviders/components/AuthenticationProvidersTable'

const ajaxJSON = jest.spyOn(ajax, 'ajaxJSON')

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
  expect(ajaxJSON).toHaveBeenCalledWith('/delete/123', { method: 'Delete' })
})

it('should handle deletion errors gracefully', async () => {
  const payload = { redirect: undefined, type: 'danger', message: 'Something went wrong' }
  ajaxJSON.mockResolvedValueOnce({ json: () => Promise.resolve(payload) } as Response)

  const wrapper = mountWrapper()
  wrapper.find('tr button.pf-c-dropdown__toggle').simulate('click')
  wrapper.find('tr button.pf-c-dropdown__menu-item[data-ouia-component-id="delete"]').simulate('click')

  wrapper.update()
    .find('Modal button.pf-m-danger').simulate('click')

  await waitForPromises(wrapper)
  expect(toast).toHaveBeenCalledWith(payload.message, 'danger')
})

it('should be able to edit an authentication provider', () => {
  const target = 0

  const wrapper = mountWrapper()
  wrapper.find('tr button.pf-c-dropdown__toggle').at(target).simulate('click')
  wrapper.find('tr button.pf-c-dropdown__menu-item[data-ouia-component-id="edit"]').simulate('click')

  expect(navigation.navigate).toHaveBeenCalledWith(defaultProps.items[target].editPath)
})
