// @flow

import React, {useState} from 'react'

import {ServiceSourceForm, ServiceDiscoveryForm, ServiceManualForm} from 'NewService'
import {createReactWrapper} from 'utilities/createReactWrapper'
import type {Api} from 'Types/Api'

type Props = {
  isServiceDiscoveryAccessible: boolean,
  isServiceDiscoveryUsable: boolean,
  serviceDiscoveryAuthenticateUrl: string,
  providerAdminServiceDiscoveryServicesPath: string,
  adminServicesPath: string,
  apiap: boolean,
  backendApis: Api[]
}

const NewServiceForm = (props: Props) => {
  const {isServiceDiscoveryAccessible, isServiceDiscoveryUsable, serviceDiscoveryAuthenticateUrl,
    providerAdminServiceDiscoveryServicesPath, adminServicesPath, apiap, backendApis} = props

  const [formMode, setFormMode] = useState('manual')
  const [loadingProjects, setLoadingProjects] = useState(false)

  const handleFormsVisibility = (event: SyntheticEvent<HTMLInputElement>) =>
    setFormMode(event.currentTarget.value)

  const formToRender = () => formMode === 'manual'
    ? <ServiceManualForm formActionPath={adminServicesPath} apiap={apiap} backendApis={backendApis} />
    : <ServiceDiscoveryForm formActionPath={providerAdminServiceDiscoveryServicesPath} apiap={apiap} setLoadingProjects={setLoadingProjects} />

  const title = apiap ? 'New Product' : 'New API'

  return (
    <React.Fragment>
      <h1>{title}</h1>
      {isServiceDiscoveryAccessible &&
        <ServiceSourceForm
          isServiceDiscoveryUsable={isServiceDiscoveryUsable}
          serviceDiscoveryAuthenticateUrl={serviceDiscoveryAuthenticateUrl}
          handleFormsVisibility={handleFormsVisibility}
          loadingProjects={loadingProjects}
          apiap={apiap}
        />
      }
      {formToRender()}
    </React.Fragment>
  )
}

const NewServiceFormWrapper = (props: Props, containerId: string) =>
  createReactWrapper(<NewServiceForm {...props} />, containerId)

export {NewServiceForm, NewServiceFormWrapper}
