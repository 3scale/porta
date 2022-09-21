import React, { FunctionComponent, useEffect } from 'react'

import { FormWrapper, ErrorMessage, ServiceDiscoveryListItems } from 'NewService/components/FormElements'
import { fetchData } from 'utilities'

import { PROJECTS_PATH } from 'NewService'

type Props = {
  formActionPath: string,
  setLoadingProjects: (loading: boolean) => void
};

const ServiceDiscoveryForm: FunctionComponent<Props> = ({
  formActionPath,
  setLoadingProjects
}) => {
  // Don't use named imports so that useState can be mocked in specs
  const [projects, setProjects] = React.useState<string[]>([])
  const [fetchErrorMessage, setFetchErrorMessage] = React.useState('')

  const fetchProjects = async () => {
    setLoadingProjects(true)

    try {
      const projects = await fetchData<string[]>(PROJECTS_PATH)
      setProjects(projects)
    } catch (error: any) {
      setFetchErrorMessage(error.message)
    } finally {
      setLoadingProjects(false)
    }
  }

  const listItemsProps = { projects, onError: setFetchErrorMessage } as const

  useEffect(() => {
    fetchProjects()
  }, [])

  const formProps = {
    id: 'service_source',
    formActionPath,
    hasHiddenServiceDiscoveryInput: true,
    submitText: 'Create Product'
  } as const

  return (
    <React.Fragment>
      {fetchErrorMessage && <ErrorMessage fetchErrorMessage={fetchErrorMessage}/>}
      <FormWrapper {...formProps}>
        <ServiceDiscoveryListItems {...listItemsProps}/>
      </FormWrapper>
    </React.Fragment>
  )
}

export { ServiceDiscoveryForm, Props }
