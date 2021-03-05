import React from 'react'
import { render } from 'enzyme'
import { ActiveMenuTitle } from 'Navigation/components/ActiveMenuTitle'

function getWrapper (activeMenu, currentApi, apiap = true) {
  return render(<ActiveMenuTitle activeMenu={activeMenu} currentApi={currentApi} apiap={apiap} />)
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

  expect(getWrapper('serviceadmin', { name: 'Test' }).text())
    .toEqual('Products')
  expect(getWrapper('backend_api', { name: 'Test' }).text())
    .toEqual('Backends')
})

it('should return the right title and icon when APIAP is disabled', () => {
  const wrapper = getWrapper('serviceadmin', { name: 'Test' }, false)
  expect(wrapper.text()).toEqual('Products')
  expect(wrapper.find('i').first().prop('class')).toContain('fa fa-cubes')
})

it('should not return a default title', () => {
  expect(getWrapper().text()).toEqual('')
})
