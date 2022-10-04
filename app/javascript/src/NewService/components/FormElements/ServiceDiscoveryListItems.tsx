import { useEffect, useState } from 'react'
import { Label, Select } from 'NewService/components/FormElements'
import { fetchData } from 'utilities'
import { BASE_PATH } from 'NewService'

import type { FunctionComponent } from 'react'

type Props = {
  projects: string[],
  onError: (err: string) => void
}

const ServiceDiscoveryListItems: FunctionComponent<Props> = (props) => {
  const { projects, onError } = props

  const [services, setServices] = useState<string[]>([])
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
    } catch (error: any) {
      onError(error.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <>
      <li className="string required" id="service_name_input">
        <Label
          htmlFor='service_namespace'
          label='Namespace'
        />
        <Select
          disabled={loading}
          id='service_namespace'
          name='service[namespace]'
          options={projects}
          onChange={e => { fetchServices(e.currentTarget.value) }}
        />
      </li>
      <li>
        <Label
          htmlFor='service_name'
          label='Name'
        />
        <Select
          disabled={loading}
          id='service_name'
          name='service[name]'
          options={services}
        />
      </li>
    </>
  )
}

export { ServiceDiscoveryListItems }
