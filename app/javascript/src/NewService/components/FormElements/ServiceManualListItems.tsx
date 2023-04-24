/* eslint-disable @typescript-eslint/no-unnecessary-condition -- FIXME: check if errors should be optional */
import { useState } from 'react'

import { Label } from 'NewService/components/FormElements/Label'

import type { FunctionComponent, ChangeEvent, SetStateAction } from 'react'
import type { ServiceFormTemplate } from 'NewService/types'

type Props = ServiceFormTemplate

const ServiceManualListItems: FunctionComponent<Props> = ({
  service,
  errors
}) => {
  const [name, setName] = useState(service.name)
  const [systemName, setSystemName] = useState(service.system_name)
  const [description, setDescription] = useState(service.description)
  const onChange = (fn: (cb: SetStateAction<string>) => void) => (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => { fn(e.currentTarget.value) }

  return (
    <>
      <li className={`string required ${errors?.name ? 'error' : ''}`} id="service_name_input">
        <Label
          required
          htmlFor="service_name"
          label="Name"
        />
        <input autoFocus id="service_name" maxLength={255} name="service[name]" type="text" value={name} onChange={onChange(setName)} />
        { !!errors.name && <p className="inline-errors">Name {errors.name}</p> }
      </li>
      <li className={`string required ${errors?.system_name ? 'error' : ''}`} id="service_system_name_input">
        <Label
          required
          htmlFor="service_system_name"
          label="System name"
        />
        <input id="service_system_name" maxLength={255} name="service[system_name]" type="text" value={systemName} onChange={onChange(setSystemName)} />
        {errors.system_name && <p className="inline-errors">{errors.system_name}</p>}
        <p className="inline-hints">Only ASCII letters, numbers, dashes and underscores are allowed.</p>
      </li>
      <li className={`text optional ${errors?.description ? 'error' : ''}`} id="service_description_input">
        <Label
          htmlFor="service_description"
          label="Description"
        />
        <textarea id="service_description" name="service[description]" rows={3} value={description} onChange={onChange(setDescription)} />
        { !!errors.description && <p className="inline-errors">{errors.description}</p> }
      </li>
    </>
  )
}
export type { Props }
export { ServiceManualListItems }
