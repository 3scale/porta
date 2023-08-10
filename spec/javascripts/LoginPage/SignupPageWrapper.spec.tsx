import { mount } from 'enzyme'

import { SignupPage } from 'Login/components/SignupPage'

import type { Props } from 'Login/components/SignupPage'

const props: Props = {
  name: 'Bob Sponge',
  path: 'bikini-bottom',
  user: {
    email: 'bob@sponge.com',
    firstname: 'Bob',
    lastname: 'Sponge',
    username: 'bobsponge',
    errors: [
      { type: 'error', message: 'username has already been taken' },
      { type: 'error', message: 'password is too short (minimum is 6 characters)' }
    ]
  }
}

it('should render itself', () => {
  const wrapper = mount(<SignupPage {...props} />)
  expect(wrapper.exists('.pf-c-login')).toEqual(true)
})

it('should render <SignupForm/> child component', () => {
  const wrapper = mount(<SignupPage {...props} />)
  expect(wrapper.exists('SignupForm')).toEqual(true)
})

it('should render error messages', () => {
  const wrapper = mount(<SignupPage {...props} />)
  expect(wrapper.find('FlashMessages .pf-m-error').length).toEqual(2)
  expect(wrapper.find('FlashMessages .pf-m-error').at(0).text()).toContain('username has already been taken')
  expect(wrapper.find('FlashMessages .pf-m-error').at(1).text()).toContain('password is too short (minimum is 6 characters)')
})
