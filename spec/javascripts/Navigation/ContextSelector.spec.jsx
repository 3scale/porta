import React from 'react'
import { mount } from 'enzyme'
import { ContextSelector } from 'Navigation/components/ContextSelector'

const audienceLink = '/audience'
const productsLink = '/products'
const backendsLink = '/backends'

const currentApi = { name: 'api 0', id: 0, link: 'foo.bar' }

function getWrapper (customProps) {
  const props = {
    currentApi: null,
    activeMenu: '',
    audienceLink: audienceLink,
    productsLink: productsLink,
    backendsLink: backendsLink,
    ...customProps
  }
  return mount(<ContextSelector {...props} />)
}

it('should render itself', () => {
  expect(getWrapper().find(ContextSelector).exists()).toEqual(true)
})

it('should have Dashboard, Audience, Products and Backends', () => {
  const wrapper = getWrapper()
  wrapper.find('.PopNavigation-trigger').simulate('click')
  expect(wrapper).toMatchSnapshot()
})

it('should not have Audience if not provided', () => {
  const wrapper = getWrapper()
  wrapper.setProps({ audienceLink: undefined })
  wrapper.find('.PopNavigation-trigger').simulate('click')
  expect(wrapper).toMatchSnapshot()
})

it('should highlight the selected context', () => {
  const wrapper = getWrapper()
  wrapper.find('.PopNavigation-trigger').simulate('click')

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
})

it('should display the current api', () => {
  const wrapper = getWrapper({ activeMenu: 'serviceadmin', currentApi })

  expect(wrapper.find('.fa-cubes').exists()).toBe(true)
  expect(wrapper.find('.PopNavigation-trigger').text()).toContain(currentApi.name)

  wrapper.setProps({ activeMenu: 'monitoring' })
  expect(wrapper.find('.fa-cubes').exists()).toBe(true)
  expect(wrapper.find('.PopNavigation-trigger').text()).toContain(currentApi.name)

  wrapper.setProps({ activeMenu: 'backend_api' })
  expect(wrapper.find('.fa-cube').exists()).toBe(true)
  expect(wrapper.find('.PopNavigation-trigger').text()).toContain(currentApi.name)
})
