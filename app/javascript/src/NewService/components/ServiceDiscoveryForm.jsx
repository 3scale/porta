// @flow

import React from 'react'
import {useState, useEffect} from 'react'

import {FormWrapper, ErrorMessage,
  ServiceDiscoveryListItems} from 'NewService/components/FormElements'
import {fetchData} from 'utilities/utils'
import type {FormProps} from 'NewService/types'

const BASE_PATH = '/p/admin/service_discovery'
const PROJECTS_PATH = `${BASE_PATH}/projects.json`

const ServiceDiscoveryForm = ({formActionPath}: {formActionPath: string}) => {
  const [projects, setProjects] = useState([])
  const [services, setServices] = useState([])
  const [fetchErrorMessage, setFetchErrorMessage] = useState('')

  const fetchProjects = async () => {
    try {
      const data = await fetchData(PROJECTS_PATH)
      setProjects(data['projects'])
      fetchServices(data.projects[0].metadata.name)
    } catch (error) {
      setFetchErrorMessage(error.message)
    }
  }

  const fetchServices = async (namespace: string) => {
    try {
      const data = await fetchData(`${BASE_PATH}/namespaces/${namespace}/services.json`)
      setServices(data['services'])
    } catch (error) {
      setFetchErrorMessage(error.message)
    }
  }

  const listItemsProps = {fetchServices, projects, services}

  useEffect(() => {
    fetchProjects()
  }, [])

  const formProps: FormProps = {
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
