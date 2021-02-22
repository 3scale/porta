// @flow

import React from 'react'
import { mount } from 'enzyme'

import { BackendSelect } from 'BackendApis'

const onShowAllSpy = jest.fn()
const onSelectSpy = jest.fn()

const newBackendPath = '/backends/new'
const backends = [
  { id: 0, name: 'API A', privateEndpoint: 'a.com' },
  { id: 1, name: 'API B', privateEndpoint: 'b.com' }
]
const defaultProps = {
  newBackendPath,
  backend: null,
  backends,
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

it('should display all items, a title and a sticky button', () => {
  const wrapper = mountWrapper()
  wrapper.find('.pf-c-select__toggle-button').simulate('click')
  expect(wrapper.find('.pf-c-select__menu li').length).toEqual(backends.length + 2)
})

it('should be able to show a modal', () => {
  const wrapper = mountWrapper()

  wrapper.find('.pf-c-select__toggle-button').simulate('click')
  wrapper.find('.pf-c-select__menu li button').last().simulate('click')

  expect(onShowAllSpy).toBeCalledTimes(1)
  expect(onSelectSpy).toBeCalledTimes(0)
})

it('should be able to select and submit an item', () => {
  const targetItem = backends[0]
  const wrapper = mountWrapper()

  wrapper.find('.pf-c-select__toggle-button').simulate('click')
  wrapper.find('.pf-c-select__menu li button').filterWhere(n => n.text().includes(targetItem.name)).simulate('click')

  expect(onSelectSpy).toBeCalledWith(targetItem)
})

it('should be able to submit the selected backend', () => {
  const targetItem = backends[0]
  const wrapper = mountWrapper({ backend: targetItem })

  const input = wrapper.find('[name="backend_api_config[backend_api_id]"]')
  expect(input.exists()).toBe(true)
  expect(input.prop('value')).toBe(targetItem.id)
})

it('should have a button to create a new backend', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find(`a[href="${newBackendPath}"]`))
})
