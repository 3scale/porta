// @flow

import React, {useEffect} from 'react'
import {Label, Select} from 'NewService/components/FormElements'

import type { Option } from 'NewService/types'

type Props = {
  fetchServices: (namespace: string) => Promise<void>,
  loading: boolean,
  projects: Option[],
  services: Option[]
}

const ServiceDiscoveryListItems = (props: Props) => {
  const {fetchServices, loading, projects, services} = props

  useEffect(() => {
    if (projects && projects.length) {
      fetchServices(projects[0].metadata.name)
    }
  }, [projects])

  return (
    <React.Fragment>
      <li id="service_name_input" className="string required">
        <Label
          htmlFor='namespace'
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

export {ServiceDiscoveryListItems}
