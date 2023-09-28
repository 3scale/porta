import { mount } from 'enzyme'

import { LoginAlert } from 'Login/components/LoginAlert'

it('should be invisible when no error', () => {
  const wrapper = mount(<LoginAlert />)
  expect(wrapper.exists('.pf-c-alert.invisible')).toEqual(true)
})

it('should render the correct alert', () => {
  expect(
    mount(<LoginAlert message="Oh no!" type="error" />)
      .exists('.pf-c-alert:not(.invisible).pf-m-danger'))
    .toEqual(true)

  expect(
    mount(<LoginAlert message="Oh no!" type="success" />)
      .exists('.pf-c-alert:not(.invisible).pf-m-success'))
    .toEqual(true)

  expect(
    mount(<LoginAlert message="Oh no!" type="notice" />)
      .exists('.pf-c-alert:not(.invisible).pf-m-info'))
    .toEqual(true)

  expect(
    // @ts-expect-error -- Test unknown type
    mount(<LoginAlert message="Oh no!" type="unknown" />)
      .exists('.pf-c-alert:not(.invisible)'))
    .toEqual(true)
})
