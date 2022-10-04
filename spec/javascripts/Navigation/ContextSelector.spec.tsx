import { mount } from 'enzyme'
import { ContextSelector } from 'Navigation/components/ContextSelector'

import type { Props } from 'Navigation/components/ContextSelector'
import type { Menu } from 'Types'

const audienceLink = '/audience'
const productsLink = '/products'
const backendsLink = '/backends'
const settingsLink = '/settings'

const defaultProps = {
  activeMenu: '' as Menu,
  audienceLink: audienceLink,
  productsLink: productsLink,
  backendsLink: backendsLink,
  settingsLink: settingsLink
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ContextSelector {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  expect(mountWrapper().find(ContextSelector).exists()).toEqual(true)
})

it('should have Dashboard, Audience, Products, Backends and Settings', () => {
  const wrapper = mountWrapper()
  wrapper.find('.pf-c-context-selector__toggle').simulate('click')
  expect(wrapper).toMatchSnapshot()
})

it('should not have Audience if not provided', () => {
  const wrapper = mountWrapper()
  wrapper.setProps({ audienceLink: undefined })
  wrapper.find('.pf-c-context-selector__toggle').simulate('click')
  expect(wrapper).toMatchSnapshot()
})

it('should highlight the selected context', () => {
  const wrapper = mountWrapper()
  wrapper.find('.pf-c-context-selector__toggle').simulate('click')

  wrapper.setProps({ activeMenu: 'buyers' })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Audience')

  wrapper.setProps({ activeMenu: 'finance' })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Audience')

  wrapper.setProps({ activeMenu: 'cms' })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Audience')

  wrapper.setProps({ activeMenu: 'site' })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Audience')

  wrapper.setProps({ activeMenu: 'dashboard' })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Dashboard')

  wrapper.setProps({ activeMenu: 'personal' })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Account Settings')

  wrapper.setProps({ activeMenu: 'account' })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Account Settings')

  wrapper.setProps({ activeMenu: 'active_docs' })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Account Settings')

  wrapper.setProps({ activeMenu: 'serviceadmin' })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Products')

  wrapper.setProps({ activeMenu: 'backend_api' })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Backends')
})

it('should display the current api', () => {
  const wrapper = mountWrapper({ activeMenu: 'serviceadmin' })

  expect(wrapper.find('.fa-cubes').exists()).toBe(true)
  expect(wrapper.find('.pf-c-context-selector__toggle').text()).toContain('Products')

  wrapper.setProps({ activeMenu: 'monitoring' })
  expect(wrapper.find('.fa-cubes').exists()).toBe(true)
  expect(wrapper.find('.pf-c-context-selector__toggle').text()).toContain('Products')

  wrapper.setProps({ activeMenu: 'backend_api' })
  expect(wrapper.find('.fa-cube').exists()).toBe(true)
  expect(wrapper.find('.pf-c-context-selector__toggle').text()).toContain('Backends')
})
