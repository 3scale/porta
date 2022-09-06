import React from 'react'
import { shallow } from 'enzyme'
import { Form } from 'Settings/components/Form'
import {
  SETTINGS_DEFAULT,
  INTEGRATION_METHOD_DEFAULTS
} from 'Settings/defaults'

function setup (customProps = {}) {
  const props = {
    ...SETTINGS_DEFAULT,
    ...customProps
  }

  const view = shallow(<Form {...props} />)

  return { view, props }
}

it('should render correctly', () => {
  const { view } = setup()
  expect(view).toMatchSnapshot()
})

it('should not render Auth Settings, Security, Credential Locations and API Gateway when Istio is selected', () => {
  const customProps = { integrationMethod: { ...INTEGRATION_METHOD_DEFAULTS, value: 'service_mesh_istio' } }
  const { view } = setup(customProps)
  expect(view).toMatchSnapshot()
})
