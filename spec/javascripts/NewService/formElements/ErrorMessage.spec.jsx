// @flow

import React from 'react'
import {mount} from 'enzyme'

import {ErrorMessage} from 'NewService/components/FormElements'

const props = {
  fetchErrorMessage: 'it failed'
}

it('should render itself', () => {
  const wrapper = mount(<ErrorMessage {...props}/>)
  expect(wrapper.find('.errorMessage').exists()).toEqual(true)
})

it('should render correct error message', () => {
  const msg = `Sorry, your request has failed with the error: it failed`
  const wrapper = mount(<ErrorMessage {...props}/>)
  expect(wrapper.find('.errorMessage').text()).toEqual(msg)
})
