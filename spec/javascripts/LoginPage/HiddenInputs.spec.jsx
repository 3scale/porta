import React from 'react'
import Enzyme, {mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {HiddenInputs} from 'LoginPage'
import {CSRFToken} from 'utilities/utils'

Enzyme.configure({adapter: new Adapter()})
const props = {
  isPasswordReset: false
}

it('should render two input hidden fields when password reset is false', () => {
  const wrapper = mount(<HiddenInputs {...props}/>)
  expect(wrapper.find('input').length).toEqual(2)
  expect(wrapper.find(CSRFToken).length).toEqual(1)
})

it('should render three input hidden fields when password reset is false', () => {
  const wrapper = mount(<HiddenInputs isPasswordReset={true}/>)
  expect(wrapper.find('input').length).toEqual(3)
  expect(wrapper.find(CSRFToken).length).toEqual(1)
})
