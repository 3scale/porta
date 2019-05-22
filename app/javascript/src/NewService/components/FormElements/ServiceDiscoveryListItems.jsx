// @flow

import React from 'react'
import {Label, Select} from 'NewService/components/FormElements'

type Props = {
  fetchServices: (namespace: string) => Promise<void>,
  projects: string[],
  services: string[]
}

const ServiceDiscoveryListItems = (props: Props) => {
  const {fetchServices, projects, services} = props
  return (
    <React.Fragment>
      <li id="service_name_input" className="string required">
        <Label
          htmlFor='namespace'
          label='Namespace'
        />
        <Select
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
          name='service[name]'
          id='service_name'
          options={services}
        />
      </li>
    </React.Fragment>
  )
}

export {ServiceDiscoveryListItems}
