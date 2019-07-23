// @flow

import React from 'react'
import {useState, useEffect} from 'react'

import {FormWrapper, ErrorMessage,
  ServiceDiscoveryListItems} from 'NewService/components/FormElements'
import {fetchData} from 'utilities/utils'

import {PROJECTS_PATH} from 'NewService'

type Props = {
  formActionPath: string,
  setLoadingProjects: boolean => void
}

const ServiceDiscoveryForm = ({formActionPath, setLoadingProjects}: Props) => {
  const [projects, setProjects] = useState([])
  const [fetchErrorMessage, setFetchErrorMessage] = useState('')

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
    submitText: 'Create Service'
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
