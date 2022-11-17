import { mount } from 'enzyme'

import { ChangePassword } from 'ChangePassword/components/ChangePassword'

import type { Props } from 'ChangePassword/components/ChangePassword'

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
