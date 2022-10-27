import { FormCollection } from 'Settings/components/Common/FormCollection'
import { FormFieldset } from 'Settings/components/Common/FormFieldset'
import { FormLegend } from 'Settings/components/Common/FormLegend'
import { TextInputGroup } from 'Settings/components/Common/TextInputGroup'
import { OidcFieldset } from 'Settings/components/OidcFieldset'

import type { FieldGroupProps, TypeItemProps } from 'Settings/types'

const OIDC_AUTH_METHOD = 'oidc'
const API_KEY_METHOD = '1'
const APP_ID_KEY_METHOD = '2'

// eslint-disable-next-line @typescript-eslint/no-type-alias
interface Props {
  isServiceMesh: boolean;
  authenticationMethod: string; // TODO: use exact types
  apiKeySettings: FieldGroupProps;
  appIdKeyPairSettings: FieldGroupProps[];
  oidcSettings: {
    basicSettings: TypeItemProps;
    flowSettings: FieldGroupProps[];
    jwtSettings: TypeItemProps;
  };
}

const AuthenticationSettingsFieldset: React.FunctionComponent<Props> = ({
  isServiceMesh,
  authenticationMethod,
  apiKeySettings,
  appIdKeyPairSettings,
  oidcSettings: { basicSettings, flowSettings, jwtSettings }
}) => {
  const isOidc = authenticationMethod === OIDC_AUTH_METHOD
  const isApiKey = authenticationMethod === API_KEY_METHOD
  const isAppIdKey = authenticationMethod === APP_ID_KEY_METHOD
  return (
    (!isServiceMesh || isOidc) && (
      <FormFieldset id="fieldset-AuthenticationSettings">
        <FormLegend>Authentication Settings</FormLegend>
        {isApiKey && <FormCollection ItemComponent={TextInputGroup} collection={[apiKeySettings]} legend="API KEY (USER_KEY) BASICS" />}
        {isAppIdKey && <FormCollection ItemComponent={TextInputGroup} collection={appIdKeyPairSettings} legend="APP_ID AND APP_KEY PAIR BASICS" />}
        {isOidc && <OidcFieldset basicSettings={basicSettings} flowSettings={flowSettings} isServiceMesh={isServiceMesh} jwtSettings={jwtSettings} />}
      </FormFieldset>
    )
  ) as React.ReactElement // Hack: Shortcircuit is not supported yet. See: https://github.com/DefinitelyTyped/DefinitelyTyped/issues/18912
}

export { AuthenticationSettingsFieldset, Props }
