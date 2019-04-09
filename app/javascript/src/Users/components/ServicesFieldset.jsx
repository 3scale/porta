// @flow

import React from 'react'

import type { Service } from 'Types'
import type { AdminSection } from 'Users/types'

/**
 * Contains a set of services that can be checked by the user.
 * @param {Service[]}       services            - The list of services.
 * @param {AdminSection[]}  selectedSections    - The Admin sections that are selected for the user.
 * @param {number[]}        selectedServicesIds - Ids of the services that are selected for the user.
 * @param {Function}        onServiceSelected   - A callback function triggered when any service is selected.
 */
const ServicesFieldset = ({ services = [], selectedSections = [], selectedServicesIds = [], onServiceSelected }: {
  services?: Service[],
  selectedSections?: AdminSection[],
  selectedServicesIds?: number[],
  onServiceSelected: number => void
}) => {
  const servicesListClassName = `ServiceAccessList`
  const allServicesChecked = !selectedSections.includes('services')

  return (
    <fieldset>
      <ol className={servicesListClassName}>
        {services.map(service => (
          <ServiceCheckbox
            key={service.id}
            service={service}
            checked={allServicesChecked || selectedServicesIds.includes(service.id)}
            disabled={allServicesChecked}
            selectedSections={selectedSections}
            onChange={onServiceSelected}
          />))}
      </ol>
    </fieldset>
  )
}

/**
 * A checkbox representing a Service.
 * @param {Service}         service           - The service this checkbox represents.
 * @param {AdminSection[]}  selectedSections  - The Admin sections that are selected for the user.
 * @param {boolean}         checked           - Whether the checkbox is selected or not.
 * @param {boolean}         disabled          - Whether the checkbox is disabled or not.
 * @param {Function}        onChange          - A callback function triggered when the checkbox is selected.
 */
const ServiceCheckbox = ({ service = {}, selectedSections, checked, disabled, onChange }: {
  service: Service,
  selectedSections: AdminSection[],
  checked: boolean,
  disabled: boolean,
  onChange: number => void
}) => {
  const { id, name } = service

  const FeatureIndicator = ({ name, text }: { name: string, text: string }) => {
    const available = selectedSections.includes(name)
    const featureIndicatorClassName = `ServiceAccessList-sectionItem ServiceAccessList-sectionItem--${name} ${available ? '' : 'is-unavailable'}`

    return <li className={featureIndicatorClassName}>{text}</li>
  }

  return (
    <li className='ServiceAccessList-item'>
      <label className='ServiceAccessList-label is-checked' htmlFor={`user_member_permission_service_ids_${id}`}>
        <input
          className='user_member_permission_service_ids'
          id={`user_member_permission_service_ids_${id}`}
          name='user[member_permission_service_ids][]'
          type='checkbox'
          value={id}
          checked={checked}
          disabled={disabled}
          onChange={() => onChange(id)}
        />
        <span className='ServiceAccessList-labelText'>{name}</span>
      </label>
      <ul className='ServiceAccessList-sections'>
        <FeatureIndicator name='plans' text='Integration & Application Plans'/>
        <FeatureIndicator name='monitoring' text='Analytics'/>
        <FeatureIndicator name='partners' text='Applications'/>
      </ul>
    </li>
  )
}

export { ServicesFieldset }
