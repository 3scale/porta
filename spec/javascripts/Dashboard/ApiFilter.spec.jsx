// @flow

import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { ApiFilter } from 'Dashboard/components/ApiFilter'

Enzyme.configure({ adapter: new Adapter() })

const apis = [
  { id: 0, name: 'api 0', link: '', type: 'backend' },
  { id: 1, name: 'api 1', link: '', type: 'backend' },
  { id: 11, name: 'api 11', link: '', type: 'backend' }
]
const domClass = 'class'

let apiFilter

beforeEach(() => {
  apiFilter = mount(<ApiFilter apis={apis} domClass={domClass} />)
})

it('should render itself', () => {
  expect(apiFilter.find('.ApiFilter').exists()).toBe(true)
})

it.skip('should filter APIs passed in props by name', () => {
  // TODO
  const input = apiFilter.find('input')
  input.simulate('change', { target: { value: 'api' } })
  input.simulate('change', { target: { value: 'api 1' } })
  input.simulate('change', { target: { value: 'api 11' } })

  // expect...
})
