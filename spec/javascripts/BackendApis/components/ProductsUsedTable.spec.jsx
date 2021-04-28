// @flow

import React from 'react'
import { mount } from 'enzyme'

import { ProductsUsedTable } from 'BackendApis'

const defaultProps = {
  products: []
}

const mountWrapper = (props) => mount(<ProductsUsedTable {...{ ...defaultProps, ...props }} />)
const mockProducts = (count) => new Array(count).fill({}).map((i, j) => ({ id: j, name: `Product ${j}`, systemName: `product_${j}`, path: `/products/${j}`, appPlans: [] }))

afterEach(() => {
  jest.resetAllMocks()
})

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should show products in a table', () => {
  const products = mockProducts(2)
  const wrapper = mountWrapper({ products })
  expect(wrapper.find('tbody tr').length).toEqual(products.length)
})

it('should be paginated and have 5 items per page', () => {
  const products = mockProducts(6)
  const wrapper = mountWrapper({ products })
  expect(wrapper.find('tbody tr').length).toEqual(5)

  wrapper.find('.pf-c-pagination button').last().simulate('click')
  expect(wrapper.find('tbody tr').length).toEqual(1)
})

it('should be able to navigate to a product overview page', () => {
  const products = mockProducts(1)
  const wrapper = mountWrapper({ products })
  expect(wrapper.find('tbody tr').first().find('Button').prop('href')).toEqual(products[0].path)
})

// FIXME: input not receiving change event
it.skip('should be filterable by name', () => {
  const products = mockProducts(10)
  const wrapper = mountWrapper({ products })

  wrapper.find('input[type="search"]').simulate('change', { target: { value: '1' } })
  wrapper.find('.pf-c-input-group button').last().simulate('click')
  wrapper.update()

  expect(wrapper.find('tbody tr').length).toEqual(2)
})
