import { useEffect, useState } from 'react'
import {
  FormGroup,
  FormSelect,
  FormSelectOption
} from '@patternfly/react-core'

import { fetchData } from 'utilities/fetchData'

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
      <FormGroup fieldId="service_namespace" label="Namespace">
        <FormSelect
          // value={option}
          required
          aria-label="Namespace"
          id="service_namespace"
          isDisabled={loading}
          name="service[namespace]"
          onChange={(value) => { void fetchServices(value ) }}
        >
          {projects.map(p => <FormSelectOption key={p} label={p} value={p} />)}
        </FormSelect>
      </FormGroup>
      <FormGroup fieldId="service_name" label="Name">
        <FormSelect
          // value={option}
          required
          aria-label="Name"
          id="service_names"
          isDisabled={loading}
          name="service[name]"
          onChange={(value) => { void fetchServices(value ) }}
        >
          {services.map(s => <FormSelectOption key={s} label={s} value={s} />)}
        </FormSelect>
      </FormGroup>
    </>
  )

  return (
    <>
      <div className="string required" id="service_name_input">
        <label htmlFor="service_namespace">
          Namespace
        </label>
        <select
          required
          disabled={loading}
          id="service_namespace"
          name="service[namespace]"
          onChange={e => { void fetchServices(e.currentTarget.value) }}
        >
          {projects.map((p) => <option key={p} value={p}>{p}</option>)}
        </select>
      </div>
      <div>
        <label htmlFor="service_name">
          Name
        </label>
        <select
          required
          disabled={loading}
          id="service_name"
          name="service[name]"
        >
          {services.map((s) => <option key={s} value={s}>{s}</option>)}
        </select>
      </div>
    </>
  )
}

export type { Props }
export { ServiceDiscoveryListItems }
