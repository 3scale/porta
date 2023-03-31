import { useEffect, useState } from 'react'

import { fetchData } from 'utilities/fetchData'
import { Label } from 'NewService/components/FormElements/Label'
import { Select } from 'NewService/components/FormElements/Select'

import type { FunctionComponent } from 'react'

export const BASE_PATH = '/p/admin/service_discovery'

interface Props {
  projects: string[];
  onError: (err: string) => void;
}

const ServiceDiscoveryListItems: FunctionComponent<Props> = (props) => {
  const { projects, onError } = props

  const [services, setServices] = useState<string[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition -- FIXME: check if projects is optional here
    if (projects?.length) {
      void fetchServices(projects[0])
    }
  }, [projects])

  const fetchServices = async (namespace: string) => {
    setLoading(true)
    setServices([])

    try {
      setServices(await fetchData<string[]>(`${BASE_PATH}/namespaces/${namespace}/services.json`))
    } catch (error: unknown) {
      onError((error as Error).message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <>
      <li className="string required" id="service_name_input">
        <Label
          htmlFor="service_namespace"
          label="Namespace"
        />
        <Select
          disabled={loading}
          id="service_namespace"
          name="service[namespace]"
          options={projects}
          onChange={e => { void fetchServices(e.currentTarget.value) }}
        />
      </li>
      <li>
        <Label
          htmlFor="service_name"
          label="Name"
        />
        <Select
          disabled={loading}
          id="service_name"
          name="service[name]"
          options={services}
        />
      </li>
    </>
  )
}

export type { Props }
export { ServiceDiscoveryListItems }
