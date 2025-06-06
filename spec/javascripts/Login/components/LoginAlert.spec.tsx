import { mount } from 'enzyme'

import { LoginAlert } from 'Login/components/LoginAlert'

it('should be invisible when no error', () => {
  const wrapper = mount(<LoginAlert />)
  expect(wrapper.exists('.pf-c-alert.invisible')).toEqual(true)
})

it('should render the correct alert', () => {
  expect(
    mount(<LoginAlert message="Oh no!" type="danger" />)
      .exists('.pf-c-alert:not(.invisible).pf-m-danger'))
    .toEqual(true)

  expect(
    mount(<LoginAlert message="Oh yes!" type="success" />)
      .exists('.pf-c-alert:not(.invisible).pf-m-success'))
    .toEqual(true)

  expect(
    mount(<LoginAlert message="Oh uh!" type="info" />)
      .exists('.pf-c-alert:not(.invisible).pf-m-info'))
    .toEqual(true)

  expect(
    mount(<LoginAlert message="Oh well!" type="warning" />)
      .exists('.pf-c-alert:not(.invisible).pf-m-warning'))
    .toEqual(true)

  expect(
    // @ts-expect-error -- Test unknown type
    mount(<LoginAlert message="Oh what?" type="unknown" />)
      .exists('.pf-c-alert:not(.invisible)'))
    .toEqual(true)
})
