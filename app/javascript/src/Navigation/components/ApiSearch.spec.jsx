import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { ApiSearch } from './ApiSearch'

Enzyme.configure({ adapter: new Adapter() })

function getWrapper (apis = []) {
  return mount(<ApiSearch apis={apis} />)
}

let apiSearch

const apis = [
  { service: { name: 'api 0', id: 0 } },
  { service: { name: 'api 1', id: 1 } },
  { service: { name: 'api 2', id: 2 } }
]

beforeEach(() => {
  apiSearch = getWrapper(apis)
})

afterEach(() => {
  apiSearch.unmount()
})

it('should render itself', () => {
  expect(apiSearch.find(ApiSearch).exists()).toBe(true)
})

it('should render all APIs when input is empty', () => {
  const input = apiSearch.find('input')

  expect(input.props().value).toBeUndefined
  expect(apiSearch.find('ul').children()).toHaveLength(apis.length)
})

it.only('should filter APIs by name', () => {
  const input = apiSearch.find('input')

  input.simulate('change', { target: { value: 'api' } })
  apiSearch.update()
  expect(apiSearch.find('ul').children()).toHaveLength(3)

  input.simulate('change', { target: { value: 'api 1' } })
  apiSearch.update()
  expect(apiSearch.find('ul').children()).toHaveLength(1)

  input.simulate('change', { target: { value: 'wubba lubba dub dub' } })
  apiSearch.update()
  expect(apiSearch.find('ul').children()).toHaveLength(0)
})
