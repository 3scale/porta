import React from 'react'
import { mount } from 'enzyme'
import { ContextSelector } from 'Navigation/components/ContextSelector'

const audienceLink = '/audience'
const productsLink = '/products'
const backendsLink = '/backends'
const settingsLink = '/settings'

const currentApi = { name: 'api 0', id: 0, link: 'foo.bar' } as const

function getWrapper (customProps: undefined | {
  activeMenu: string,
  currentApi: {
    id: number,
    link: string,
    name: string
  }
}) {
  const props = {
    currentApi: null,
    activeMenu: 'dashboard',
    audienceLink: audienceLink,
    productsLink: productsLink,
    backendsLink: backendsLink,
    settingsLink: settingsLink,
    ...customProps
  } as const
  return mount(<ContextSelector {...props} />)
}

it('should render itself', () => {
  expect(getWrapper().find(ContextSelector).exists()).toEqual(true)
})

it('should have Dashboard, Audience, Products, Backends and Settings', () => {
  const wrapper = getWrapper()
  wrapper.find('.pf-c-context-selector__toggle').simulate('click')
  expect(wrapper).toMatchSnapshot()
})

it('should not have Audience if not provided', () => {
  const wrapper = getWrapper()
  wrapper.setProps({ audienceLink: undefined })
  wrapper.find('.pf-c-context-selector__toggle').simulate('click')
  expect(wrapper).toMatchSnapshot()
})

it('should highlight the selected context', () => {
  const wrapper = getWrapper()
  wrapper.find('.pf-c-context-selector__toggle').simulate('click')

  wrapper.setProps({ activeMenu: 'buyers', currentApi: null })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Audience')

  wrapper.setProps({ activeMenu: 'finance', currentApi: null })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Audience')

  wrapper.setProps({ activeMenu: 'cms', currentApi: null })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Audience')

  wrapper.setProps({ activeMenu: 'site', currentApi: null })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Audience')

  wrapper.setProps({ activeMenu: 'dashboard', currentApi })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Dashboard')

  wrapper.setProps({ activeMenu: 'personal', currentApi })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Account Settings')

  wrapper.setProps({ activeMenu: 'account', currentApi })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Account Settings')

  wrapper.setProps({ activeMenu: 'active_docs', currentApi })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Account Settings')

  wrapper.setProps({ activeMenu: 'serviceadmin', currentApi })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Products')

  wrapper.setProps({ activeMenu: 'backend_api', currentApi })
  expect(wrapper.find('.current-context')).toHaveLength(1)
  expect(wrapper.find('.current-context').text()).toEqual('Backends')
})

it('should display the current api', () => {
  const wrapper = getWrapper({ activeMenu: 'serviceadmin', currentApi })

  expect(wrapper.find('.fa-cubes').exists()).toBe(true)
  expect(wrapper.find('.pf-c-context-selector__toggle').text()).toContain('Products')

  wrapper.setProps({ activeMenu: 'monitoring' })
  expect(wrapper.find('.fa-cubes').exists()).toBe(true)
  expect(wrapper.find('.pf-c-context-selector__toggle').text()).toContain('Products')

  wrapper.setProps({ activeMenu: 'backend_api' })
  expect(wrapper.find('.fa-cube').exists()).toBe(true)
  expect(wrapper.find('.pf-c-context-selector__toggle').text()).toContain('Backends')
})
