import { mount } from 'enzyme'
import { FlashMessages } from 'LoginPage'

it('should render proper error message', () => {
  const wrapper = mount(<FlashMessages flashMessages={[{ type: 'error', message: 'You lost!' }]} />)
  expect(wrapper.find('.pf-m-error').exists()).toEqual(true)
  expect(wrapper.find('.pf-m-error').text()).toContain('You lost!')
})

it('should render proper notification message', () => {
  const wrapper = mount(<FlashMessages flashMessages={[{ type: 'notice', message: 'You are advised!' }]} />)
  expect(wrapper.find('.pf-m-notice').exists()).toEqual(true)
  expect(wrapper.find('.pf-m-notice').text()).toContain('You are advised!')
})
