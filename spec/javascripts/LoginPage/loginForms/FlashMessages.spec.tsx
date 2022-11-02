import { mount } from 'enzyme'

import { FlashMessages } from 'LoginPage/loginForms/FlashMessages'

it('should render proper error message', () => {
  const wrapper = mount(<FlashMessages flashMessages={[{ type: 'error', message: 'You lost!' }]} />)
  expect(wrapper.exists('.pf-m-error')).toEqual(true)
  expect(wrapper.find('.pf-m-error').text()).toContain('You lost!')
})

it('should render proper notification message', () => {
  const wrapper = mount(<FlashMessages flashMessages={[{ type: 'notice', message: 'You are advised!' }]} />)
  expect(wrapper.exists('.pf-m-notice')).toEqual(true)
  expect(wrapper.find('.pf-m-notice').text()).toContain('You are advised!')
})
