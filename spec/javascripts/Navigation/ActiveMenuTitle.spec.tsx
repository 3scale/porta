
import { render } from 'enzyme'

import { ActiveMenuTitle } from 'Navigation/components/ActiveMenuTitle'

import type { Props } from 'Navigation/components/ActiveMenuTitle'
import type { Menu } from 'Types'

const renderWrapper = (props: Props) => render(<ActiveMenuTitle {...props} />)

it('should return the proper title depending on the current menu', () => {
  expect(renderWrapper({ activeMenu: 'dashboard' }).text()).toEqual('Dashboard')

  expect(renderWrapper({ activeMenu: 'personal' }).text()).toEqual('Account Settings')
  expect(renderWrapper({ activeMenu: 'account' }).text()).toEqual('Account Settings')
  expect(renderWrapper({ activeMenu: 'active_docs' }).text()).toEqual('Account Settings')

  expect(renderWrapper({ activeMenu: 'buyers' }).text()).toEqual('Audience')
  expect(renderWrapper({ activeMenu: 'finance' }).text()).toEqual('Audience')
  expect(renderWrapper({ activeMenu: 'cms' }).text()).toEqual('Audience')
  expect(renderWrapper({ activeMenu: 'site' }).text()).toEqual('Audience')
  expect(renderWrapper({ activeMenu: 'settings' }).text()).toEqual('Audience')
  expect(renderWrapper({ activeMenu: 'audience' }).text()).toEqual('Audience')
  expect(renderWrapper({ activeMenu: 'applications' }).text()).toEqual('Audience')

  expect(renderWrapper({ activeMenu: 'serviceadmin' }).text()).toEqual('Products')
  expect(renderWrapper({ activeMenu: 'backend_api' }).text()).toEqual('Backends')

  expect(renderWrapper({ activeMenu: 'quickstarts' }).text()).toEqual('--')
})

it('should not return a default title', () => {
  expect(renderWrapper({ activeMenu: '' as Menu }).text()).toEqual('')
})
