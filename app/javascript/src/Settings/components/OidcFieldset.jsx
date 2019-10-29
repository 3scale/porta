// @flow

import React, {useState} from 'react'
import { FormFieldset, FormLegend } from 'Form'
import { Checkbox } from '@patternfly/react-core'
import { FormCollection, TypeItemCombo } from 'Settings/components/Common'
import type { TypeItemProps, FieldGroupProps } from 'Settings/types'

const Basics = (props: TypeItemProps) => (
  <TypeItemCombo {...props} legend='OIDC BASICS' inputType='url' />
)

const JsonWebToken = (props: TypeItemProps) => (
  <TypeItemCombo {...props} legend='JSON Web Token (JWT) Claim with ClientID' inputType='text' />
)

const FlowItem = ({name, label, checked}: FieldGroupProps) => {
  const [ isChecked, setIsChecked ] = useState(checked)
  const onChange = (check, _e) => setIsChecked(check)
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

const AuthorizationFlow = (props: {collection: FieldGroupProps[]}) => (
  <FormCollection {...props} ItemComponent={FlowItem} legend='OIDC Authorization flow' />
)

type Props = {
  isServiceMesh: boolean,
  basicSettings: TypeItemProps,
  jwtSettings: TypeItemProps,
  flowSettings: FieldGroupProps[]
}

const OidcFieldset = ({isServiceMesh, basicSettings, jwtSettings, flowSettings}: Props) => (
  <FormFieldset id='fieldset-Oidc'>
    <FormLegend>OPENID CONNECT (OIDC)</FormLegend>
    <Basics {...basicSettings} />
    { !isServiceMesh && <AuthorizationFlow collection={flowSettings} /> }
    { !isServiceMesh && <JsonWebToken {...jwtSettings} /> }
  </FormFieldset>
)

export {
  OidcFieldset
}
