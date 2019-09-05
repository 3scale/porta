// @flow

import React from 'react'
import Enzyme, {shallow} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {BackendApiSelect} from 'NewService/components/FormElements'

Enzyme.configure({adapter: new Adapter()})

const backendApis = [
  { id: 1, name: 'backend 1', link: '', type: 'backend' },
  { id: 2, name: 'backend 2', link: '', type: 'backend' }
]

it('should render itself', () => {
  const wrapper = shallow(<BackendApiSelect backendApis={backendApis} />)
  expect(wrapper.exists()).toBe(true)
})

it('should display a select to choose a backend API from, or create a new one', () => {
  const wrapper = shallow(<BackendApiSelect backendApis={backendApis} />)
  const select = wrapper.find('select[name="service[backend_api]"]')

  expect(select.containsAllMatchingElements(
    backendApis.map(api => <option value={api.id}>{api.name}</option>)
  )).toBe(true)

  expect(select.containsMatchingElement(
    <option value="">Create a new Backend API</option>
  )).toBe(true)
})
