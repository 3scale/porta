import { mount } from 'enzyme'

import { ChangePasswordPage } from 'Login/components/ChangePasswordPage'

import type { Props } from 'Login/components/ChangePasswordPage'

const defaultProps: Props = {
  lostPasswordToken: 'foo',
  url: 'foo/bar',
  alerts: []
}

const mountWrapper = (props: Partial<Props> = {}) => mount(<ChangePasswordPage {...{ ...defaultProps, ...props }} />)

it('should render itself', () => {
  const wrapper = mountWrapper()
  expect(wrapper).toMatchSnapshot()
})

it('should render with server side errors when present', () => {
  const wrapper = mountWrapper({ alerts: [{ type: 'danger', message: 'Ooops!' }] })
  expect(wrapper).toMatchSnapshot()
})

// TODO: Test Form errors and interaction.
