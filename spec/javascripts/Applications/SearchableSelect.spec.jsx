// @flow

import React from 'react'
import Enzyme, { mount } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import { SearchableSelect } from 'Applications/SearchableSelect'

Enzyme.configure({ adapter: new Adapter() })

let wrapper

function getWrapper () {
  const props = { options: [], onOptionSelected: jest.fn(), label: '', formId: '', formName: '' }

  wrapper = mount(<SearchableSelect {...props} />)
}

beforeEach(() => {
  getWrapper()
})

afterEach(() => {
  wrapper.unmount()
})

it('should render itself', () => {
  expect(wrapper.find(SearchableSelect).exists()).toBe(true)
})
