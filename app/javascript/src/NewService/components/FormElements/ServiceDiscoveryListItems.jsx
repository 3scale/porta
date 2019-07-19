// @flow

import React from 'react'
import {Label, Select} from 'NewService/components/FormElements'

type Props = {
  fetchServices: (namespace: string) => Promise<void>,
  loading: boolean,
  projects: Option[],
  services: Option[]
}

const ServiceDiscoveryListItems = (props: Props) => {
  const {fetchServices, loading, projects, services} = props
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
          onChange={(e) => fetchServices(e.currentTarget.value)}
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
