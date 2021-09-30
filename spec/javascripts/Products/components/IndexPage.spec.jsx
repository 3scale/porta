// @flow

import React from 'react'
import { mount } from 'enzyme'

import { IndexPage } from 'Products'

const defaultProps = {
  products: [],
  productsCount: 0
}

const mountWrapper = (props) => mount(<IndexPage {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper.exists()).toBe(true)
})
