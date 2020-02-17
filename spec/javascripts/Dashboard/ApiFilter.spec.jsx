// @flow

import React from 'react'
import { mount } from 'enzyme'

import { ApiFilter } from 'Dashboard/components/ApiFilter'

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

it('should filter APIs passed in props by name', () => {
  // remove / add mean class 'hidden' from DOM Element
  const remove = jest.fn()
  const add = jest.fn()
  jest.spyOn(document, 'getElementById').mockReturnValue({
    classList: { remove, add }
  })

  const input = apiFilter.find('input')

  // Filter first all apis
  input.simulate('change', { target: { value: 'api' } })

  expect(remove).toHaveBeenCalledTimes(apis.length)
  expect(add).toHaveBeenCalledTimes(0)

  remove.mockReset()
  add.mockReset()

  // Filter only last one
  input.simulate('change', { target: { value: 'api 11' } })

  expect(remove).toHaveBeenCalledTimes(1)
  expect(add).toHaveBeenCalledTimes(2)
})
