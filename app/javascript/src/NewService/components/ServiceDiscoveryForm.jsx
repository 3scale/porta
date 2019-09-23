// @flow

import React, {useEffect} from 'react'

import {FormWrapper, ErrorMessage,
  ServiceDiscoveryListItems} from 'NewService/components/FormElements'
import {fetchData} from 'utilities/utils'

import {PROJECTS_PATH} from 'NewService'

type Props = {
  formActionPath: string,
  apiap: boolean,
  setLoadingProjects: boolean => void
}

const ServiceDiscoveryForm = ({formActionPath, apiap, setLoadingProjects}: Props) => {
  // Don't use named imports so that useState can be mocked in specs
  const [projects, setProjects] = React.useState([])
  const [fetchErrorMessage, setFetchErrorMessage] = React.useState('')

  const fetchProjects = async () => {
    setLoadingProjects(true)

    try {
      const projects = await fetchData<string[]>(PROJECTS_PATH)
      setProjects(projects)
    } catch (error) {
      setFetchErrorMessage(error.message)
    } finally {
      setLoadingProjects(false)
    }
  }

  const listItemsProps = {projects, onError: setFetchErrorMessage}

  useEffect(() => {
    fetchProjects()
  }, [])

  const formProps = {
    id: 'service_source',
    formActionPath,
    hasHiddenServiceDiscoveryInput: true,
    submitText: apiap ? 'Create Product' : 'Create Service'
  }

  return (
    <React.Fragment>
      {fetchErrorMessage && <ErrorMessage fetchErrorMessage={fetchErrorMessage}/>}
      <FormWrapper {...formProps}>
        <ServiceDiscoveryListItems {...listItemsProps}/>
      </FormWrapper>
    </React.Fragment>
  )
}

export {
  ServiceDiscoveryForm
}
