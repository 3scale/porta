import * as React from 'react'
import { FunctionComponent } from 'react'

import { Checkbox, CheckboxProps } from '@patternfly/react-core'
import { FormCollection, FormFieldset, FormLegend, TypeItemCombo } from 'Settings/components/Common'
import { TypeItemProps, FieldGroupProps } from 'Settings/types'

const Basics: FunctionComponent<TypeItemProps> = (props) => (
  <TypeItemCombo {...props} legend='OIDC BASICS' />
)

const JsonWebToken: FunctionComponent<TypeItemProps> = (props) => (
  <TypeItemCombo {...props} legend='JSON Web Token (JWT) Claim with ClientID' />
)

const FlowItem: FunctionComponent<FieldGroupProps> = ({ name, label, checked }) => {
  const [ isChecked, setIsChecked ] = React.useState(checked)
  const onChange: CheckboxProps['onChange'] = (check, _e) => setIsChecked(check)
  return (
    <Checkbox
      id={`service_proxy_attributes_oidc_configuration_attributes_${name}_input`}
      name={`service[proxy_attributes][oidc_configuration_attributes][${name}]`}
      label={label}
      isChecked={isChecked}
      onChange={onChange}
    />
  )
}

const AuthorizationFlow: FunctionComponent<{ collection: FieldGroupProps[] }> = (props) => (
  <FormCollection {...props} ItemComponent={FlowItem} legend='OIDC Authorization flow' />
)

type Props = {
  isServiceMesh: boolean,
  basicSettings: TypeItemProps,
  jwtSettings: TypeItemProps,
  flowSettings: FieldGroupProps[]
};

const OidcFieldset: FunctionComponent<Props> = ({
  isServiceMesh,
  basicSettings,
  jwtSettings,
  flowSettings
}) => (
  <FormFieldset id='fieldset-Oidc'>
    <FormLegend>OPENID CONNECT (OIDC)</FormLegend>
    <Basics {...basicSettings} />
    { !isServiceMesh && <AuthorizationFlow collection={flowSettings} /> }
    { !isServiceMesh && <JsonWebToken {...jwtSettings} /> }
  </FormFieldset>
)

export { OidcFieldset, Props }
