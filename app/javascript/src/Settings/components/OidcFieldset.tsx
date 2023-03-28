/* eslint-disable react/jsx-props-no-spreading -- FIXME */
import { useState } from 'react'
import { Checkbox } from '@patternfly/react-core'

import { TypeItemCombo } from 'Settings/components/Common/TypeItemCombo'
import { FormCollection } from 'Settings/components/Common/FormCollection'
import { FormFieldset } from 'Settings/components/Common/FormFieldset'
import { FormLegend } from 'Settings/components/Common/FormLegend'

import type { CheckboxProps } from '@patternfly/react-core'
import type { FunctionComponent } from 'react'
import type { FieldGroupProps, TypeItemProps } from 'Settings/types'

interface Props {
  isServiceMesh: boolean;
  basicSettings: TypeItemProps;
  jwtSettings: TypeItemProps;
  flowSettings: FieldGroupProps[];
}

const OidcFieldset: FunctionComponent<Props> = ({
  isServiceMesh,
  basicSettings,
  jwtSettings,
  flowSettings
}) => (
  <FormFieldset id="fieldset-Oidc">
    <FormLegend>OPENID CONNECT (OIDC)</FormLegend>
    <Basics {...basicSettings} />
    {!isServiceMesh && <AuthorizationFlow collection={flowSettings} />}
    {!isServiceMesh && <JsonWebToken {...jwtSettings} />}
  </FormFieldset>
)

// eslint-disable-next-line react/no-multi-comp -- FIXME: move to its own file
const Basics: FunctionComponent<TypeItemProps> = (props) => (
  <TypeItemCombo {...props} legend="OIDC BASICS" />
)

// eslint-disable-next-line react/no-multi-comp -- FIXME: move to its own file
const JsonWebToken: FunctionComponent<TypeItemProps> = (props) => (
  <TypeItemCombo {...props} legend="JSON Web Token (JWT) Claim with ClientID" />
)

// eslint-disable-next-line react/no-multi-comp -- FIXME: move to its own file
const FlowItem: FunctionComponent<FieldGroupProps> = ({ name, label, checked }) => {
  const [isChecked, setIsChecked] = useState(checked)
  const onChange: CheckboxProps['onChange'] = (check) => { setIsChecked(check) }
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

// eslint-disable-next-line react/no-multi-comp -- FIXME: move to its own file
const AuthorizationFlow: FunctionComponent<{ collection: FieldGroupProps[] }> = (props) => (
  <FormCollection {...props} ItemComponent={FlowItem} legend="OIDC Authorization flow" />
)

export type { Props }
export { OidcFieldset }
