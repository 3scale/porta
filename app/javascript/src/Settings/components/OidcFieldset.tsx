/* eslint-disable react/jsx-props-no-spreading */
/* eslint-disable react/no-multi-comp */
import { useState } from 'react'
import { Checkbox } from '@patternfly/react-core'
import { TypeItemCombo } from 'Settings/components/Common/TypeItemCombo'
import { FormCollection } from 'Settings/components/Common/FormCollection'
import { FormFieldset } from 'Settings/components/Common/FormFieldset'
import { FormLegend } from 'Settings/components/Common/FormLegend'

import type { CheckboxProps } from '@patternfly/react-core'
import type { FunctionComponent } from 'react'
import type { FieldGroupProps, TypeItemProps } from 'Settings/types'

const Basics: FunctionComponent<TypeItemProps> = (props) => (
  <TypeItemCombo {...props} legend='OIDC BASICS' />
)

const JsonWebToken: FunctionComponent<TypeItemProps> = (props) => (
  <TypeItemCombo {...props} legend='JSON Web Token (JWT) Claim with ClientID' />
)

const FlowItem: FunctionComponent<FieldGroupProps> = ({ name, label, checked }) => {
  const [ isChecked, setIsChecked ] = useState(checked)
  const onChange: CheckboxProps['onChange'] = (check) => setIsChecked(check)
  return (
    <Checkbox
      id={`service_proxy_attributes_oidc_configuration_attributes_${name}_input`}
      isChecked={isChecked}
      label={label}
      name={`service[proxy_attributes][oidc_configuration_attributes][${name}]`}
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
}

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
