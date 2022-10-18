import { useState } from 'react'
import { ServiceDiscoveryForm } from 'NewService/components/ServiceDiscoveryForm'
import { ServiceManualForm } from 'NewService/components/ServiceManualForm'
import { ServiceSourceForm } from 'NewService/components/ServiceSourceForm'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { FunctionComponent } from 'react'
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
}

const NewServiceForm: FunctionComponent<Props> = ({
  template,
  isServiceDiscoveryAccessible,
  isServiceDiscoveryUsable,
  serviceDiscoveryAuthenticateUrl,
  providerAdminServiceDiscoveryServicesPath,
  adminServicesPath,
  backendApis
}) => {
  const [formMode, setFormMode] = useState('manual')
  const [loadingProjects, setLoadingProjects] = useState(false)

  const handleFormsVisibility = (event: React.SyntheticEvent<HTMLInputElement>) => setFormMode(event.currentTarget.value)

  return (
    <>
      <h1>New Product</h1>
      <div className="new-service-form">
        {isServiceDiscoveryAccessible && (
          <ServiceSourceForm
            handleFormsVisibility={handleFormsVisibility}
            isServiceDiscoveryUsable={isServiceDiscoveryUsable}
            loadingProjects={loadingProjects}
            serviceDiscoveryAuthenticateUrl={serviceDiscoveryAuthenticateUrl}
          />
        )}
        {formMode === 'manual'
          ? <ServiceManualForm backendApis={backendApis} formActionPath={adminServicesPath} template={template} />
          : <ServiceDiscoveryForm formActionPath={providerAdminServiceDiscoveryServicesPath} setLoadingProjects={setLoadingProjects} />}
      </div>
    </>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const NewServiceFormWrapper = (props: Props, containerId: string): void => createReactWrapper(<NewServiceForm {...props} />, containerId)

export { NewServiceForm, NewServiceFormWrapper, Props }
