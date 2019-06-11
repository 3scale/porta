import React from 'react'
import Enzyme, {mount} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {FlashMessages} from 'LoginPage'

Enzyme.configure({adapter: new Adapter()})

it('should render proper error message', () => {
  const wrapper = mount(<FlashMessages flashMessages={[{type: 'error', message: 'You lost!'}]}/>)
  expect(wrapper.find('.pf-m-error').exists()).toEqual(true)
  expect(wrapper.find('.pf-m-error').text()).toContain('You lost!')
})

it('should render proper notification message', () => {
  const wrapper = mount(<FlashMessages flashMessages={[{type: 'notice', message: 'You are advised!'}]}/>)
  expect(wrapper.find('.pf-m-notice').exists()).toEqual(true)
  expect(wrapper.find('.pf-m-notice').text()).toContain('You are advised!')
})
