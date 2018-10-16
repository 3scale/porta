import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { ContextSelector } from './ContextSelector'

Enzyme.configure({ adapter: new Adapter() })

function getWrapper (apis = [], currentApi, controllerName) {
  return mount(<ContextSelector apis={apis} currentApi={currentApi} controllerName={controllerName} />)
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

describe('When there is only 1 service', () => {
  it('should neither have a search field or a list of apis', () => {
    contextSelector = getWrapper(apis.slice(0, 1))
    expect(contextSelector.props().apis).toHaveLength(1)

    expect(contextSelector.find('input').exists()).toEqual(false)

    const apiList = contextSelector.find('.PopNavigation-results')
    expect(apiList.exists()).toEqual(false)
  })
})

describe('When there are many services', () => {
  it('should have a search field after audience', () => {
    const searchField = contextSelector.find('input')
    expect(searchField.exists()).toEqual(true)
    expect(searchField.type()).toEqual('input')
    expect(searchField.props().placeholder).toEqual('Type the API name')
  })

  it('should have a list of apis after the search field', () => {
    expect(contextSelector.props().apis).toHaveLength(apis.length)

    const apiList = contextSelector.find('.PopNavigation-results')
    expect(apiList.exists()).toEqual(true)
    expect(apiList.type()).toEqual('ul')
    expect(apiList.children().length).toEqual(apis.length)
  })
})
