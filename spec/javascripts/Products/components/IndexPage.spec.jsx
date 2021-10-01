// @flow

import React from 'react'
import { mount } from 'enzyme'

import { IndexPage } from 'Products'
import { mockLocation } from 'utilities/test-utils'

const defaultProps = {
  products: [],
  productsCount: 0
}

const mountWrapper = (props) => mount(<IndexPage {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})

it('should have a paginated table', () => {
  const productsCount = 10
  mockLocation(`href://foo.bar/metrics?per_page=2&page=2`)
  const wrapper = mountWrapper({ productsCount })
  const pagination = wrapper.find('.pf-c-pagination').first()

  expect(pagination.find('[aria-label="Current page"]').first().prop('value')).toBe(2)

  pagination.find('button[data-action="first"]').simulate('click')
  expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('page=1'))

  pagination.find('button[data-action="previous"]').simulate('click')
  expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('page=1'))

  pagination.find('button[data-action="next"]').simulate('click')
  expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('page=3'))

  pagination.find('button[data-action="last"]').simulate('click')
  expect(window.location.replace).toHaveBeenCalledWith(expect.stringContaining('page=3'))

  expect(pagination.find('.pf-c-options-menu__toggle-text').text()).toMatch(`3 - 4 of ${productsCount}`)
})
