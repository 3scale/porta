import * as React from 'react';

import { FormCollection, FormFieldset, FormLegend, TextInputGroup } from 'Settings/components/Common'
import { OidcFieldset } from 'Settings/components/OidcFieldset'
import type { FieldGroupProps, TypeItemProps } from 'Settings/types'

const OIDC_AUTH_METHOD = 'oidc'
const API_KEY_METHOD = '1'
const APP_ID_KEY_METHOD = '2'

type Props = {
  isServiceMesh: boolean,
  authenticationMethod: string,
  apiKeySettings: FieldGroupProps,
  appIdKeyPairSettings: FieldGroupProps[],
  oidcSettings: {
    basicSettings: TypeItemProps,
    flowSettings: FieldGroupProps[],
    jwtSettings: TypeItemProps
  }
};

const AuthenticationSettingsFieldset = (
  {
    isServiceMesh,
    authenticationMethod,
    apiKeySettings,
    appIdKeyPairSettings,
    oidcSettings,
  }: Props,
): React.ReactElement => {
  const isOidc = authenticationMethod === OIDC_AUTH_METHOD
  const isApiKey = authenticationMethod === API_KEY_METHOD
  const isAppIdKey = authenticationMethod === APP_ID_KEY_METHOD
  return (
    (!isServiceMesh || isOidc) && <FormFieldset id='fieldset-AuthenticationSettings'>
      <FormLegend>Authentication Settings</FormLegend>
      { isApiKey && <FormCollection collection={[apiKeySettings]} ItemComponent={TextInputGroup} legend='API KEY (USER_KEY) BASICS' /> }
      { isAppIdKey && <FormCollection collection={appIdKeyPairSettings} ItemComponent={TextInputGroup} legend='APP_ID AND APP_KEY PAIR BASICS' /> }
      { isOidc && <OidcFieldset {...oidcSettings} isServiceMesh={isServiceMesh} /> }
    </FormFieldset>
  )
}

export {
  AuthenticationSettingsFieldset
}
