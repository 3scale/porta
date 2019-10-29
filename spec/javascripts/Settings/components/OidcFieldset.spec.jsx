import React from 'react'
import { shallow } from 'enzyme'
import { OidcFieldset } from 'Settings/components/OidcFieldset'
import { OIDC_SETTINGS_DEFAULTS } from 'Settings/defaults'

function setup (customProps = {}) {
  const props = {
    ...OIDC_SETTINGS_DEFAULTS,
    isServiceMesh: false,
    ...customProps
  }

  const view = shallow(<OidcFieldset {...props} />)

  return { view, props }
}

it('should render correctly', () => {
  const { view } = setup()
  expect(view).toMatchSnapshot()
})

it('should render only Basics  when Service Mesh is active', () => {
  const customProps = { isServiceMesh: true }
  const { view } = setup(customProps)
  expect(view).toMatchSnapshot()
})
