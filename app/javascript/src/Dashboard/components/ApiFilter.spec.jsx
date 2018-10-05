import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { ApiFilter } from './ApiFilter'

Enzyme.configure({ adapter: new Adapter() })

function getWrapper (apis = [], displayApis) {
  return mount(<ApiFilter apis={apis} displayApis={displayApis} />)
}

let apiFilter

const apis = [
  { service: { name: 'api 0' } },
  { service: { name: 'api 1' } },
  { service: { name: 'api 2' } }
]

beforeEach(() => {
  apiFilter = getWrapper()
})

afterEach(() => {
  apiFilter.unmount()
})

it('should render itself', () => {
  expect(apiFilter.find('.ApiFilter').exists()).toBe(true)
})

it('should filter APIs passed in props by name', () => {
  const displayApis = jest.fn()
  apiFilter = getWrapper(apis, displayApis)

  const input = apiFilter.find('input')
  input.simulate('change', { target: { value: 'api' } })
  input.simulate('change', { target: { value: 'api 1' } })
  input.simulate('change', { target: { value: 'api 11' } })

  expect(displayApis.mock.calls.length).toEqual(3)
  expect(displayApis.mock.calls[0][0]).toEqual(apis)
  expect(displayApis.mock.calls[1][0]).toEqual([{ service: { name: 'api 1' } }])
  expect(displayApis.mock.calls[2][0]).toEqual([])
})
