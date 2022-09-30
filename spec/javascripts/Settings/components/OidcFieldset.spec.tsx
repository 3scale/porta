import { shallow } from 'enzyme'

import { OidcFieldset, Props } from 'Settings/components/OidcFieldset'
import { OIDC_SETTINGS_DEFAULTS } from 'Settings/defaults'

const defaultProps: Props = {
  ...OIDC_SETTINGS_DEFAULTS,
  isServiceMesh: false
}

const mountWrapper = (props: Partial<Props> = {}) => shallow(<OidcFieldset { ...{ ...defaultProps, ...props } } />)

it('should render correctly', () => {
  const view = mountWrapper()
  expect(view).toMatchSnapshot()
})

it('should render only Basics when Service Mesh is active', () => {
  const customProps = { isServiceMesh: true }
  const view = mountWrapper(customProps)
  expect(view).toMatchSnapshot()
})
