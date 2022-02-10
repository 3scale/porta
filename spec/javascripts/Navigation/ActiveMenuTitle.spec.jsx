// @flow

import React from 'react'
import { render } from 'enzyme'
import { ActiveMenuTitle } from 'Navigation/components/ActiveMenuTitle'
import type { Menu } from 'Types'

function getWrapper (activeMenu: Menu, currentApi) {
  return render(<ActiveMenuTitle activeMenu={activeMenu} currentApi={currentApi} />)
}

it('should return the proper title depending on the current menu', () => {
  expect(getWrapper('dashboard').text()).toEqual('Dashboard')

  expect(getWrapper('personal').text()).toEqual('Account Settings')
  expect(getWrapper('account').text()).toEqual('Account Settings')
  expect(getWrapper('active_docs').text()).toEqual('Account Settings')

  expect(getWrapper('buyers').text()).toEqual('Audience')
  expect(getWrapper('finance').text()).toEqual('Audience')
  expect(getWrapper('cms').text()).toEqual('Audience')
  expect(getWrapper('site').text()).toEqual('Audience')
  expect(getWrapper('settings').text()).toEqual('Audience')
  expect(getWrapper('audience').text()).toEqual('Audience')
  expect(getWrapper('applications').text()).toEqual('Audience')

  expect(getWrapper('serviceadmin', { name: 'Test' }).text()).toEqual('Products')
  expect(getWrapper('backend_api', { name: 'Test' }).text()).toEqual('Backends')

  expect(getWrapper('quick_starts', { name: 'Test' }).text()).toEqual('--')
})

it('should not return a default title', () => {
  // $FlowIgnore[incompatible-call] expected to pass no activeMenu
  expect(getWrapper().text()).toEqual('')
})
