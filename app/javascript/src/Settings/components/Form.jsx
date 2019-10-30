// @flow

import * as React from 'react'
import { useState } from 'react'
import { FormFieldset, FormLegend } from 'Form'
import { FormCollection, TextInputGroup, RadioFieldset } from 'Settings/components/Common'
import { AuthenticationSettingsFieldset } from 'Settings/components/AuthenticationSettingsFieldset'
import type { SettingsProps as Props } from 'Settings/types'

const SERVICE_MESH_INTEGRATION = 'service_mesh_istio'
const PROXY_HOSTED_INTEGRATION = 'hosted'

const Form = ({
  isProxyCustomUrlActive,
  integrationMethod,
  authenticationMethod,
  proxyEndpoints,
  authenticationSettings,
  credentialsLocation,
  security,
  gatewayResponse
}: Props) => {
  const [ selectedIntegrationMethod, setSelectedIntegrationMethod ] = useState(integrationMethod.value)
  const [ selectedAuthenticationMethod, setSelectedAuthenticationMethod ] = useState(authenticationMethod.value)
  const onChange = (setState) => (_checked, e) => setState(e.currentTarget.value)
  const isServiceMesh = selectedIntegrationMethod === SERVICE_MESH_INTEGRATION
  const isProxyHosted = selectedIntegrationMethod === PROXY_HOSTED_INTEGRATION
  const isProxyUrlsReadOnly = !isProxyCustomUrlActive && isProxyHosted
  const customProxyEndpoints = proxyEndpoints.map(endpoint =>
    ({ ...endpoint, readOnly: isProxyUrlsReadOnly, isDefaultValue: isProxyUrlsReadOnly }))

  return (
    <React.Fragment>
      <RadioFieldset {...integrationMethod} onChange={onChange(setSelectedIntegrationMethod)} value={selectedIntegrationMethod} legend='Integration' />
      { !isServiceMesh && <FormCollection collection={customProxyEndpoints} ItemComponent={TextInputGroup} legend='API gateway' /> }
      <RadioFieldset {...authenticationMethod} onChange={onChange(setSelectedAuthenticationMethod)} value={selectedAuthenticationMethod} legend='Authentication' />
      <AuthenticationSettingsFieldset
        isServiceMesh={isServiceMesh}
        authenticationMethod={selectedAuthenticationMethod}
        {...authenticationSettings}
      />
      { !isServiceMesh && <React.Fragment>
        <RadioFieldset {...credentialsLocation} legend='Credentials Location' />
        <FormCollection collection={security} ItemComponent={TextInputGroup} legend='Security' />
        <FormFieldset id='fieldset-GatewayResponse'>
          <FormLegend>Gateway Response</FormLegend>
          {gatewayResponse.map(settings => (
            <FormCollection key={settings.legend} collection={settings.collection} ItemComponent={TextInputGroup} legend={settings.legend} />
          ))}
        </FormFieldset>
      </React.Fragment> }
    </React.Fragment>
  )
}

export {
  Form
}
