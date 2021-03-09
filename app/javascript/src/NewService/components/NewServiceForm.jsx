// @flow

import * as React from 'react'

import {ServiceSourceForm, ServiceDiscoveryForm, ServiceManualForm} from 'NewService'
import {createReactWrapper} from 'utilities/createReactWrapper'
import type {Api} from 'Types/Api'
import type {ServiceFormTemplate} from 'NewService/types'

type Props = {
  template: ServiceFormTemplate,
  isServiceDiscoveryAccessible: boolean,
  isServiceDiscoveryUsable: boolean,
  serviceDiscoveryAuthenticateUrl: string,
  providerAdminServiceDiscoveryServicesPath: string,
  adminServicesPath: string,
  apiap: boolean,
  backendApis: Api[]
}

const NewServiceForm = (props: Props): React.Node => {
  const {template, isServiceDiscoveryAccessible, isServiceDiscoveryUsable, serviceDiscoveryAuthenticateUrl,
    providerAdminServiceDiscoveryServicesPath, adminServicesPath, apiap, backendApis} = props

  const [formMode, setFormMode] = React.useState('manual')
  const [loadingProjects, setLoadingProjects] = React.useState(false)

  const handleFormsVisibility = (event: SyntheticEvent<HTMLInputElement>) =>
    setFormMode(event.currentTarget.value)

  const formToRender = () => formMode === 'manual'
    ? <ServiceManualForm template={template} formActionPath={adminServicesPath} apiap={apiap} backendApis={backendApis} />
    : <ServiceDiscoveryForm formActionPath={providerAdminServiceDiscoveryServicesPath} apiap={apiap} setLoadingProjects={setLoadingProjects} />

  const title = apiap ? 'New Product' : 'New API'

  return (
    <React.Fragment>
      <h1>{title}</h1>
      <div className="new-service-form">
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
      </div>
    </React.Fragment>
  )
}

const NewServiceFormWrapper = (props: Props, containerId: string): void =>
  createReactWrapper(<NewServiceForm {...props} />, containerId)

export {NewServiceForm, NewServiceFormWrapper}
