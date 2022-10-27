/* eslint-disable react/jsx-props-no-spreading -- FIXME: remove this spreading */
import { useState } from 'react'
import { AuthenticationSettingsFieldset } from 'Settings/components/AuthenticationSettingsFieldset'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { SETTINGS_DEFAULT } from 'Settings/defaults'
import { FormCollection } from 'Settings/components/Common/FormCollection'
import { FormFieldset } from 'Settings/components/Common/FormFieldset'
import { FormLegend } from 'Settings/components/Common/FormLegend'
import { RadioFieldset } from 'Settings/components/Common/RadioFieldset'
import { TextInputGroup } from 'Settings/components/Common/TextInputGroup'

import type { FieldCatalogProps, FieldGroupProps, LegendCollectionProps, TypeItemProps } from 'Settings/types'

const SERVICE_MESH_INTEGRATION = 'service_mesh_istio'
const PROXY_HOSTED_INTEGRATION = 'hosted'

interface Props {
  isProxyCustomUrlActive: boolean;
  integrationMethod: FieldCatalogProps & FieldGroupProps;
  authenticationMethod: FieldCatalogProps & FieldGroupProps;
  proxyEndpoints: FieldGroupProps[];
  authenticationSettings: {
    appIdKeyPairSettings: FieldGroupProps[];
    apiKeySettings: FieldGroupProps;
    oidcSettings: {
      basicSettings: TypeItemProps;
      flowSettings: FieldGroupProps[];
      jwtSettings: TypeItemProps;
    };
  };
  credentialsLocation: FieldCatalogProps & FieldGroupProps;
  security: FieldGroupProps[];
  gatewayResponse: LegendCollectionProps[];
}

const Form: React.FunctionComponent<Props> = ({
  isProxyCustomUrlActive,
  integrationMethod,
  authenticationMethod,
  proxyEndpoints,
  authenticationSettings,
  credentialsLocation,
  security,
  gatewayResponse
}) => {
  const [selectedIntegrationMethod, setSelectedIntegrationMethod] = useState(integrationMethod.value)
  const [selectedAuthenticationMethod, setSelectedAuthenticationMethod] = useState(authenticationMethod.value)
  const onChange = (setState: (cb: string | ((value: string) => string)) => void) => (_checked: string, e: React.SyntheticEvent<HTMLButtonElement>) => { setState(e.currentTarget.value) }
  const isServiceMesh = selectedIntegrationMethod === SERVICE_MESH_INTEGRATION
  const isProxyHosted = selectedIntegrationMethod === PROXY_HOSTED_INTEGRATION
  const isProxyUrlsReadOnly = !isProxyCustomUrlActive && isProxyHosted
  const customProxyEndpoints = proxyEndpoints.map(endpoint => ({
    ...endpoint,
    readOnly: isProxyUrlsReadOnly,
    isDefaultValue: isProxyUrlsReadOnly
  }))

  return (
    <>
      <RadioFieldset {...integrationMethod} legend="Integration" value={selectedIntegrationMethod} onChange={onChange(setSelectedIntegrationMethod)} />
      { !isServiceMesh && <FormCollection ItemComponent={TextInputGroup} collection={customProxyEndpoints} legend="API gateway" /> }
      <RadioFieldset {...authenticationMethod} legend="Authentication" value={selectedAuthenticationMethod} onChange={onChange(setSelectedAuthenticationMethod)} />
      <AuthenticationSettingsFieldset
        authenticationMethod={selectedAuthenticationMethod}
        isServiceMesh={isServiceMesh}
        {...authenticationSettings}
      />
      { !isServiceMesh && (
        <>
          <RadioFieldset {...credentialsLocation} legend="Credentials Location" />
          <FormCollection ItemComponent={TextInputGroup} collection={security} legend="Security" />
          <FormFieldset id="fieldset-GatewayResponse">
            <FormLegend>Gateway Response</FormLegend>
            {gatewayResponse.map(settings => (
              <FormCollection key={settings.legend} ItemComponent={TextInputGroup} collection={settings.collection} legend={settings.legend} />
            ))}
          </FormFieldset>
        </>
      ) }
    </>
  )
}

// eslint-disable-next-line @typescript-eslint/default-param-last -- Why is settings even treated as optional
const FormWrapper = (settings: Props = SETTINGS_DEFAULT, elementId: string): void => { createReactWrapper(<Form {...settings} />, elementId) }

export { Form, FormWrapper, Props }
