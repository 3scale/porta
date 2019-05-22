// @flow

import React, {useState} from 'react'

import {ServiceSourceForm, ServiceDiscoveryForm, ServiceManualForm} from 'NewService'
import {createReactWrapper} from 'utilities/createReactWrapper'

type Props = {
  isServiceDiscoveryUsable: boolean,
  serviceDiscoveryAuthenticateUrl: string,
  providerAdminServiceDiscoveryServicesPath: string,
  adminServicesPath: string
}

const NewServiceForm = (props: Props) => {
  const {isServiceDiscoveryUsable, serviceDiscoveryAuthenticateUrl,
    providerAdminServiceDiscoveryServicesPath, adminServicesPath} = props

  const [formMode, setFormMode] = useState('manual')

  const handleFormsVisibility = (event: SyntheticEvent<HTMLSelectElement>) => {
    setFormMode(event.currentTarget.value)
  }

  const formToRender = () => formMode === 'manual'
    ? <ServiceManualForm formActionPath={adminServicesPath}/>
    : <ServiceDiscoveryForm formActionPath={providerAdminServiceDiscoveryServicesPath}/>

  return (
    <React.Fragment>
      <h1>New API</h1>
      <ServiceSourceForm
        isServiceDiscoveryUsable={isServiceDiscoveryUsable}
        serviceDiscoveryAuthenticateUrl={serviceDiscoveryAuthenticateUrl}
        handleFormsVisibility={handleFormsVisibility}
      />
      {formToRender()}
    </React.Fragment>
  )
}

const NewServiceFormWrapper = (props: Props, containerId: string) =>
  createReactWrapper(<NewServiceForm {...props} />, containerId)

export {NewServiceForm, NewServiceFormWrapper}
