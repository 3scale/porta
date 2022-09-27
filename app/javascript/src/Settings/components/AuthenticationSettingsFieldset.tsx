import * as React from 'react'

import { FormCollection, FormFieldset, FormLegend, TextInputGroup } from 'Settings/components/Common'
import { OidcFieldset } from 'Settings/components/OidcFieldset'
import { FieldGroupProps, TypeItemProps } from 'Settings/types'

const OIDC_AUTH_METHOD = 'oidc'
const API_KEY_METHOD = '1'
const APP_ID_KEY_METHOD = '2'

type Props = {
  isServiceMesh: boolean,
  authenticationMethod: string, // TODO: use exact types
  apiKeySettings: FieldGroupProps,
  appIdKeyPairSettings: FieldGroupProps[],
  oidcSettings: {
    basicSettings: TypeItemProps,
    flowSettings: FieldGroupProps[],
    jwtSettings: TypeItemProps
  }
};

const AuthenticationSettingsFieldset: React.FunctionComponent<Props> = ({
  isServiceMesh,
  authenticationMethod,
  apiKeySettings,
  appIdKeyPairSettings,
  oidcSettings
}) => {
  const isOidc = authenticationMethod === OIDC_AUTH_METHOD
  const isApiKey = authenticationMethod === API_KEY_METHOD
  const isAppIdKey = authenticationMethod === APP_ID_KEY_METHOD
  return (
    (!isServiceMesh || isOidc) && (
      <FormFieldset id='fieldset-AuthenticationSettings'>
        <FormLegend>Authentication Settings</FormLegend>
        { isApiKey && <FormCollection collection={[apiKeySettings]} ItemComponent={TextInputGroup} legend='API KEY (USER_KEY) BASICS' /> }
        { isAppIdKey && <FormCollection collection={appIdKeyPairSettings} ItemComponent={TextInputGroup} legend='APP_ID AND APP_KEY PAIR BASICS' /> }
        { isOidc && <OidcFieldset {...oidcSettings} isServiceMesh={isServiceMesh} /> }
      </FormFieldset>
    )
  ) as React.ReactElement // Hack: Shortcircuit is not supported yet. See: https://github.com/DefinitelyTyped/DefinitelyTyped/issues/18912
}

export { AuthenticationSettingsFieldset, Props }
