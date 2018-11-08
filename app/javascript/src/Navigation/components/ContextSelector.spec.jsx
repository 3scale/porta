import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { ContextSelector } from './ContextSelector'

Enzyme.configure({ adapter: new Adapter() })

function getWrapper (apis = [], audienceLink) {
  return mount(<ContextSelector apis={apis} audienceLink={audienceLink} />)
}

let contextSelector

const apis = [
  { service: { name: 'api 0', id: 0, link: 'foo.bar' } },
  { service: { name: 'api 1', id: 1 } },
  { service: { name: 'api 2', id: 2 } }
]
const audienceLink = 'foo.bar'

beforeEach(() => {
  contextSelector = getWrapper(apis, audienceLink)
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

it('should have a Audience option after Dashboard, only if audience link is defined', () => {
  const audience = contextSelector.find('#context-menu').childAt(1)
  expect(audience.exists()).toEqual(true)
  expect(audience.text()).toEqual('Audience')
  expect(audience.find('a').props().href).toEqual(audienceLink)
})

it('should not have a Audience option when audience link is undefined', () => {
  contextSelector = getWrapper(apis, undefined)
  let audience = contextSelector.find('a').filterWhere(a => a.text() === 'Audience')
  expect(audience.exists()).toEqual(false)
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
  beforeEach(() => {
    contextSelector = getWrapper(apis.slice(0, 1), audienceLink)
    expect(contextSelector.props().apis.length).toEqual(1)
  })

  it('should not have a search field', () => {
    expect(contextSelector.props().apis).toHaveLength(1)
    expect(contextSelector.find('input').exists()).toEqual(false)
  })

  it('should have the only api after Audience', () => {
    const api = contextSelector.find('#context-menu').childAt(2)
    expect(api.exists()).toEqual(true)
    expect(api.text()).toEqual('api 0')
  })

  it('should mark the api as unauthorized when link is undefined', () => {
    contextSelector = getWrapper(apis.slice(0, 1), audienceLink)
    expect(contextSelector.find('.unauthorized')).toHaveLength(0)

    contextSelector = getWrapper(apis.slice(1, 2), audienceLink)
    expect(contextSelector.find('.unauthorized')).toHaveLength(1)
  })
})

describe('When there are many services', () => {
  beforeEach(() => {
    expect(contextSelector.props().apis.length).toBeGreaterThan(0)
  })

  it('should have a search field after audience', () => {
    const searchField = contextSelector.find('#context-menu').childAt(2)

    expect(searchField.exists()).toEqual(true)
    expect(searchField.find('input').exists()).toEqual(true)
    expect(searchField.find('input').props().placeholder).toEqual('Type the API name')
  })

  it('should have a list of apis after the search field', () => {
    expect(contextSelector.find('#context-menu').childAt(3).find('.PopNavigation-results').exists())
      .toEqual(true)
  })

  it('should render all APIs when input is empty', () => {
    const input = contextSelector.find('input')
    expect(input.props().value).toBeUndefined

    const apiList = contextSelector.find('.PopNavigation-results').children()
    expect(apiList).toHaveLength(apis.length)
    expect(apiList.containsAllMatchingElements(
      apis.map(api => <li><a><i />{api.service.name}</a></li>)
    )).toEqual(true)
  })

  it('should filter APIs by name', () => {
    const input = contextSelector.find('input')

    input.simulate('change', { target: { value: 'api' } })
    expect(contextSelector.find('.PopNavigation-results').children()).toHaveLength(3)

    input.simulate('change', { target: { value: 'api 1' } })
    expect(contextSelector.find('.PopNavigation-results').children()).toHaveLength(1)

    input.simulate('change', { target: { value: 'wubba lubba dub dub' } })
    expect(contextSelector.find('.PopNavigation-results').children()).toHaveLength(0)
  })

  it('should mark apis as unauthorized when link is undefined', () => {
    const apiList = contextSelector.find('.PopNavigation-results').children()
    expect(apiList.find('.unauthorized')).toHaveLength(2)
  })
})
