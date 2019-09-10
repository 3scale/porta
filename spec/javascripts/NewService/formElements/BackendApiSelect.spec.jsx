// @flow

import React from 'react'
import {act} from 'react-dom/test-utils'
import Enzyme, {shallow} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {BackendApiSelect} from 'NewService/components/FormElements'

Enzyme.configure({adapter: new Adapter()})

const props = {
  backendApis: []
}

it('should render itself', () => {
  const wrapper = shallow(<BackendApiSelect {...props} />)
  expect(wrapper.find('#service_act_as_product_input').exists()).toEqual(true)
})

it('should render Act as Product checkbox', () => {
  const wrapper = shallow(<BackendApiSelect {...props} />)
  expect(wrapper.find('input[name="service[act_as_product]"]').exists()).toEqual(true)
})

it('should not render select element when Act as Product checkbox is unchecked', () => {
  const wrapper = shallow(<BackendApiSelect {...props} />)
  expect(wrapper.find('select[name="service[backend_api]"]').exists()).toEqual(false)
})

it('should render select element when Act as Product checkbox is checked', () => {
  const wrapper = shallow(<BackendApiSelect {...props} />)
  expect(wrapper.find('select[name="service[backend_api]"]').exists()).toEqual(false)
  const eventObj = {currentTarget: {checked: true}}
  act(() => {
    wrapper.find('input[name="service[act_as_product]"]').simulate('change', eventObj)
  })
  expect(wrapper.find('select[name="service[backend_api]"]').exists()).toEqual(true)
})
