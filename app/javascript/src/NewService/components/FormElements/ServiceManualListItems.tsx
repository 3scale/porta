import { FunctionComponent, useState } from 'react'
import { Label } from 'NewService/components/FormElements'
import type { ServiceFormTemplate } from 'NewService/types'

type Props = ServiceFormTemplate;

const ServiceManualListItems: FunctionComponent<Props> = ({
  service,
  errors
}) => {
  const [name, setName] = useState(service.name)
  const [systemName, setSystemName] = useState(service.system_name)
  const [description, setDescription] = useState(service.description)
  const onChange = (fn: (arg1: ((arg1: any | string) => any | string) | any | string) => void) => (e: any) => fn(e.currentTarget.value)

  return (
     <>
      <li id="service_name_input" className={`string required ${errors && errors.name ? 'error' : ''}`}>
        <Label
          htmlFor='service_name'
          label='Name'
          required
        />
        <input onChange={onChange(setName)} value={name} maxLength={255} id="service_name" type="text" name="service[name]" autoFocus={true}/>
        { !!errors.name && <p className="inline-errors">{errors.name}</p> }
      </li>
      <li id="service_system_name_input" className={`string required ${errors && errors.system_name ? 'error' : ''}`}>
        <Label
          htmlFor='service_system_name'
          label='System name'
          required
        />
        <input onChange={onChange(setSystemName)} value={systemName} maxLength={255} id="service_system_name" type="text" name="service[system_name]"/>
        <p className={`${errors.system_name ? 'inline-errors' : 'inline-hints'}`}>
          Only ASCII letters, numbers, dashes and underscores are allowed.
        </p>
      </li>
      <li id="service_description_input" className={`text optional ${errors && errors.description ? 'error' : ''}`}>
        <Label
          htmlFor='service_description'
          label='Description'
        />
        <textarea onChange={onChange(setDescription)} value={description} rows={3} id="service_description" name="service[description]"></textarea>
        { !!errors.description && <p className="inline-errors">{errors.description}</p> }
      </li>
     </>
  )
}
export { ServiceManualListItems }
