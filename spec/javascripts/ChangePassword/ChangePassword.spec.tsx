import React from 'react';
import { mount } from 'enzyme'
import { ChangePassword } from 'ChangePassword'

it('should render itself', () => {
  const props = {
    lostPasswordToken: 'foo',
    url: 'foo/bar',
    errors: []
  } as const
  const wrapper = mount(<ChangePassword {...props} />)
  expect(wrapper).toMatchSnapshot()
})

it('should render with server side errors when present', () => {
  const props = {
    lostPasswordToken: 'foo',
    url: 'foo/bar',
    errors: [{type: 'error', message: 'Ooops!'}]
  } as const
  const wrapper = mount(<ChangePassword {...props} />)
  expect(wrapper).toMatchSnapshot()
})

// TODO: Test Form errors and interaction.
