// @flow

import React from 'react'
import {useState, useEffect} from 'react'

import {FormWrapper, ErrorMessage,
  ServiceDiscoveryListItems} from 'NewService/components/FormElements'
import {fetchData} from 'utilities/utils'
import type {Option} from 'NewService/types'

const BASE_PATH = '/p/admin/service_discovery'
const PROJECTS_PATH = `${BASE_PATH}/projects.json`

type Props = {
  formActionPath: string,
  setLoadingProjects: boolean => void
}

const ServiceDiscoveryForm = ({formActionPath, setLoadingProjects}: Props) => {
  const [projects, setProjects] = useState([])
  const [services, setServices] = useState([])
  const [fetchErrorMessage, setFetchErrorMessage] = useState('')
  const [loading, setLoading] = useState(true)

  const fetchProjects = async () => {
    setLoadingProjects(true)

    try {
      const { projects } = await fetchData<{projects: Option[]}>(PROJECTS_PATH)
      setProjects(projects)
    } catch (error) {
      setFetchErrorMessage(error.message)
    } finally {
      setLoadingProjects(false)
    }
  }

  const fetchServices = async (namespace: string) => {
    setLoading(true)
    setServices([])

    try {
      const { services } = await fetchData<{services: Option[]}>(`${BASE_PATH}/namespaces/${namespace}/services.json`)
      setServices(services)
    } catch (error) {
      setFetchErrorMessage(error.message)
    } finally {
      setLoading(false)
    }
  }

  const listItemsProps = {fetchServices, projects, services, loading}

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
