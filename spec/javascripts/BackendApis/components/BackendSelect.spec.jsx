// @flow

import React from 'react'
import { mount } from 'enzyme'

import { BackendSelect } from 'BackendApis'

const onCreateBackendSpy = jest.fn()
const onShowAllSpy = jest.fn()
const onSelectSpy = jest.fn()

const newBackendPath = '/backends/new'
const backends = [
  { id: 0, name: 'API A', privateEndpoint: 'a.com', systemName: 'API_A' },
  { id: 1, name: 'API B', privateEndpoint: 'b.com', systemName: 'API_B' }
]
const defaultProps = {
  newBackendPath,
  backend: null,
  backends,
  onCreateNewBackend: onCreateBackendSpy,
  onShowAll: onShowAllSpy,
  onSelect: onSelectSpy
}

const mountWrapper = (props) => mount(<BackendSelect {...{ ...defaultProps, ...props }} />)

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper({ isOpen: true })
  expect(wrapper.exists()).toBe(true)
})

describe('when there are more than 20 backends', () => {
  const backends = new Array(21).fill({}).map((_, i) => ({ id: i, name: `API ${i}`, privateEndpoint: `api/${i}`, systemName: `api_${i}` }))

  it('should have a table with Name, Private Base URL and Last updated', () => {
    const wrapper = mountWrapper({ backends })
    wrapper.find('.pf-c-select__toggle-button').simulate('click')
    wrapper.find('.pf-c-select__menu li button').last().simulate('click')

    expect(wrapper.find('TableModal').prop('isOpen')).toBe(true)
    expect(wrapper.find('TableModal').prop('cells')).toMatchObject([
      { title: 'Name', propName: 'name' },
      { title: 'Private Base URL', propName: 'privateEndpoint' },
      { title: 'Last updated', propName: 'updatedAt' }
    ])
  })
})
