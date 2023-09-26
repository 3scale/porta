import { mount } from 'enzyme'

import { SignupPage } from 'Login/components/SignupPage'

import type { Props } from 'Login/components/SignupPage'

const defaultProps: Props = {
  flashMessages: [],
  name: 'Best API',
  path: 'bikini-bottom',
  user: {
    email: 'bob@sponge.com',
    firstname: 'Bob',
    lastname: 'Sponge',
    username: 'bobsponge'
  }
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<SignupPage {...{ ...defaultProps, ...props }} />)

it('should render a login title', () => {
  const wrapper = mountWrapper()
  expect(wrapper.find('.pf-c-login__main-header').text()).toEqual('Signup to Best API')
})
