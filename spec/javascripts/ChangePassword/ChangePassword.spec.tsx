import { mount } from 'enzyme'

import { ChangePassword } from 'Login/components/ChangePasswordPage'

import type { Props } from 'Login/components/ChangePasswordPage'

it('should render itself', () => {
  const props: Props = {
    lostPasswordToken: 'foo',
    url: 'foo/bar',
    errors: []
  }
  const wrapper = mount(<ChangePassword {...props} />)
  expect(wrapper).toMatchSnapshot()
})

it('should render with server side errors when present', () => {
  const props: Props = {
    lostPasswordToken: 'foo',
    url: 'foo/bar',
    errors: [{ type: 'error', message: 'Ooops!' }]
  }
  const wrapper = mount(<ChangePassword {...props} />)
  expect(wrapper).toMatchSnapshot()
})

// TODO: Test Form errors and interaction.
