import { shallow } from 'enzyme'
import { Form } from 'Settings/components/Form'
import { INTEGRATION_METHOD_DEFAULTS, SETTINGS_DEFAULT } from 'Settings/defaults'

import type { Props } from 'Settings/components/Form'

const defaultProps: Props = SETTINGS_DEFAULT

const mountWrapper = (props: Partial<Props> = {}) => shallow(<Form {...{ ...defaultProps, ...props }} />)

it('should render correctly', () => {
  const view = mountWrapper()
  expect(view).toMatchSnapshot()
})

it('should not render Auth Settings, Security, Credential Locations and API Gateway when Istio is selected', () => {
  const customProps = { integrationMethod: { ...INTEGRATION_METHOD_DEFAULTS, value: 'service_mesh_istio' } }
  const view = mountWrapper(customProps)
  expect(view).toMatchSnapshot()
})
