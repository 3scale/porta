import React from 'react'
import { shallow } from 'enzyme'

import { AuthenticationSettingsFieldset } from 'Settings/components/AuthenticationSettingsFieldset'
import { AUTHENTICATION_SETTINGS_DEFAULT } from 'Settings/defaults'

function setup (customProps = {}) {
  const props = {
    ...AUTHENTICATION_SETTINGS_DEFAULT,
    ...{
      isServiceMesh: false,
      authenticationMethod: '1'
    },
    ...customProps
  }

  const view = shallow(<AuthenticationSettingsFieldset {...props} />)

  return { view, props }
}

it('should render correctly', () => {
  const { view } = setup()
  expect(view).toMatchSnapshot()
})

it('should not render when Service Mesh is active', () => {
  const customProps = { isServiceMesh: true }
  const { view } = setup(customProps)
  expect(view).toMatchSnapshot()
})

it('should render only OIDC when Service Mesh is active and Oidc method is selected', () => {
  const customProps = { isServiceMesh: true, authenticationMethod: 'oidc' }
  const { view } = setup(customProps)
  expect(view).toMatchSnapshot()
})
