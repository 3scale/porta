// @flow

import * as React from 'react'
import { useState, useEffect } from 'react'
import { Label, Select } from 'NewService/components/FormElements'
import { fetchData } from 'utilities'
import { BASE_PATH } from 'NewService'

type Props = {
  projects: string[],
  onError: (err: string) => void
}

const ServiceDiscoveryListItems = (props: Props): React.Node => {
  const { projects, onError } = props

  const [services, setServices] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (projects && projects.length) {
      fetchServices(projects[0])
    }
  }, [projects])

  const fetchServices = async (namespace: string) => {
    setLoading(true)
    setServices([])

    try {
      const services = await fetchData<string[]>(`${BASE_PATH}/namespaces/${namespace}/services.json`)
      setServices(services)
    } catch (error) {
      onError(error.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <React.Fragment>
      <li id="service_name_input" className="string required">
        <Label
          htmlFor='service_namespace'
          label='Namespace'
        />
        <Select
          disabled={loading}
          name='service[namespace]'
          id='service_namespace'
          onChange={e => { fetchServices(e.currentTarget.value) }}
          options={projects}
        />
      </li>
      <li>
        <Label
          htmlFor='service_name'
          label='Name'
        />
        <Select
          disabled={loading}
          name='service[name]'
          id='service_name'
          options={services}
        />
      </li>
    </React.Fragment>
  )
}

export { ServiceDiscoveryListItems }
