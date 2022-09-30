import { useState } from 'react'
import { ServiceSourceForm, ServiceDiscoveryForm, ServiceManualForm } from 'NewService'
import { createReactWrapper } from 'utilities'
import type { Api } from 'Types/Api'
import type { ServiceFormTemplate } from 'NewService/types'

type Props = {
  template: ServiceFormTemplate,
  isServiceDiscoveryAccessible: boolean,
  isServiceDiscoveryUsable: boolean,
  serviceDiscoveryAuthenticateUrl: string,
  providerAdminServiceDiscoveryServicesPath: string,
  adminServicesPath: string,
  backendApis: Api[]
};

const NewServiceForm = (props: Props): React.ReactElement => {
  const { template, isServiceDiscoveryAccessible, isServiceDiscoveryUsable, serviceDiscoveryAuthenticateUrl,
    providerAdminServiceDiscoveryServicesPath, adminServicesPath, backendApis } = props

  const [formMode, setFormMode] = useState('manual')
  const [loadingProjects, setLoadingProjects] = useState(false)

  const handleFormsVisibility = (event: React.SyntheticEvent<HTMLInputElement>) =>
    setFormMode(event.currentTarget.value)

  const formToRender = () => formMode === 'manual'
    ? <ServiceManualForm template={template} formActionPath={adminServicesPath} backendApis={backendApis} />
    : <ServiceDiscoveryForm formActionPath={providerAdminServiceDiscoveryServicesPath} setLoadingProjects={setLoadingProjects} />

  return (
     <>
      <h1>New Product</h1>
      <div className="new-service-form">
        {isServiceDiscoveryAccessible &&
          <ServiceSourceForm
            isServiceDiscoveryUsable={isServiceDiscoveryUsable}
            serviceDiscoveryAuthenticateUrl={serviceDiscoveryAuthenticateUrl}
            handleFormsVisibility={handleFormsVisibility}
            loadingProjects={loadingProjects}
          />
        }
        {formToRender()}
      </div>
     </>
  )
}

const NewServiceFormWrapper = (props: Props, containerId: string): void => createReactWrapper(<NewServiceForm {...props} />, containerId)

export { NewServiceForm, NewServiceFormWrapper }
