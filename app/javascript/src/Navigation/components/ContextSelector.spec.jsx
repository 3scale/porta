import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { ContextSelector } from './ContextSelector'

Enzyme.configure({ adapter: new Adapter() })

function getWrapper (apis = []) {
  return mount(<ContextSelector apis={apis} />)
}

let contextSelector

const apis = [
  { service: { name: 'api 0', id: 0 } },
  { service: { name: 'api 1', id: 1 } },
  { service: { name: 'api 2', id: 2 } }
]

beforeEach(() => {
  contextSelector = getWrapper(apis)
})

afterEach(() => {
  contextSelector.unmount()
})

it('should render itself', () => {
  expect(contextSelector.find(ContextSelector).exists()).toEqual(true)
})

it('should have a Dashboard option on top', () => {
  const dashboard = contextSelector.find('#context-menu').childAt(0)
  expect(dashboard.exists()).toEqual(true)
  expect(dashboard.text()).toEqual('Dashboard')
  expect(dashboard.find('a').props().href).not.toBeUndefined()
})

it('should have a Audience option after Dashboard', () => {
  const audience = contextSelector.find('#context-menu').childAt(1)
  expect(audience.exists()).toEqual(true)
  expect(audience.text()).toEqual('Audience')
  expect(audience.find('a').props().href).not.toBeUndefined()
})

it('should highlight the selected context', () => {
  contextSelector.setProps({ activeMenu: 'buyers', currentApi: null })
  expect(contextSelector.find('.current-context')).toHaveLength(1)
  expect(contextSelector.find('.current-context').text()).toEqual('Audience')

  contextSelector.setProps({ activeMenu: 'finance', currentApi: null })
  expect(contextSelector.find('.current-context')).toHaveLength(1)
  expect(contextSelector.find('.current-context').text()).toEqual('Audience')

  contextSelector.setProps({ activeMenu: 'cms', currentApi: null })
  expect(contextSelector.find('.current-context')).toHaveLength(1)
  expect(contextSelector.find('.current-context').text()).toEqual('Audience')

  contextSelector.setProps({ activeMenu: 'site', currentApi: null })
  expect(contextSelector.find('.current-context')).toHaveLength(1)

  contextSelector.setProps({ activeMenu: 'dashboard', currentApi: apis[0] })
  expect(contextSelector.find('.current-context')).toHaveLength(1)
  expect(contextSelector.find('.current-context').text()).toEqual('Dashboard')

  // For the particular APIs
  contextSelector.setProps({ activeMenu: 'serviceadmin', currentApi: apis[1] })
  expect(contextSelector.find('.current-context')).toHaveLength(1)
  expect(contextSelector.find('.current-context').text()).toEqual('api 1')

  contextSelector.setProps({ activeMenu: 'monitoring', currentApi: apis[2] })
  expect(contextSelector.find('.current-context')).toHaveLength(1)
  expect(contextSelector.find('.current-context').text()).toEqual('api 2')
})

describe('When there is only 1 service', () => {
  it('should not have a search field', () => {
    contextSelector = getWrapper(apis.slice(0, 1))
    expect(contextSelector.props().apis).toHaveLength(1)

    expect(contextSelector.find('input').exists()).toEqual(false)
  })

  it('should have the only api after Audience', () => {
    contextSelector = getWrapper(apis.slice(0, 1))
    expect(contextSelector.props().apis).toHaveLength(1)

    const api = contextSelector.find('#context-menu').childAt(2)
    expect(api.exists()).toEqual(true)
    expect(api.text()).toEqual('api 0')
  })
})

describe('When there are many services', () => {
  it('should have a search field after audience', () => {
    const searchField = contextSelector.find('#context-menu').childAt(2)

    expect(searchField.exists()).toEqual(true)
    expect(searchField.find('input').exists()).toEqual(true)
    expect(searchField.find('input').props().placeholder).toEqual('Type the API name')
  })

  it('should have a list of apis after the search field', () => {
    expect(contextSelector.props().apis).toHaveLength(apis.length)

    const apiList = contextSelector.find('#context-menu').children().slice(3)
    expect(apiList).toHaveLength(apis.length)
    expect(apiList.containsAllMatchingElements(
      apis.map(api => <li><a>{api.service.name}</a></li>)
    )).toEqual(true)
  })

  it('should render all APIs when input is empty', () => {
    const input = contextSelector.find('input')
    const apiList = contextSelector.find('#context-menu').children().slice(3)

    expect(input.props().value).toBeUndefined
    expect(apiList).toHaveLength(apis.length)
  })

  it('should filter APIs by name', () => {
    const input = contextSelector.find('input')

    input.simulate('change', { target: { value: 'api' } })
    expect(contextSelector.find('#context-menu').children().slice(3)).toHaveLength(3)

    input.simulate('change', { target: { value: 'api 1' } })
    expect(contextSelector.find('#context-menu').children().slice(3)).toHaveLength(1)

    input.simulate('change', { target: { value: 'wubba lubba dub dub' } })
    expect(contextSelector.find('#context-menu').children().slice(3)).toHaveLength(0)
  })
})
