import type { Api } from 'Types'
import type { AdminSection } from 'Users/types'

/**
 * Contains a set of services that can be checked by the user.
 * @param {Api[]}           services            - The list of services.
 * @param {AdminSection[]}  selectedSections    - The Admin sections that are selected for the user.
 * @param {number[]}        selectedServicesIds - Ids of the services that are selected for the user.
 * @param {Function}        onServiceSelected   - A callback function triggered when any service is selected.
 */
interface Props {
  services?: Api[];
  selectedSections?: AdminSection[];
  selectedServicesIds?: number[];
  onServiceSelected: (id: number) => void;
}

const ServicesFieldset: React.FunctionComponent<Props> = ({
  services = [],
  selectedSections = [],
  selectedServicesIds = [],
  onServiceSelected
}) => {
  const servicesListClassName = 'ServiceAccessList'
  const allServicesChecked = !selectedSections.includes('services')

  return (
    <fieldset>
      <ol className={servicesListClassName}>
        {services.map(service => (
          <ServiceCheckbox
            key={service.id}
            checked={allServicesChecked || selectedServicesIds.includes(service.id)}
            disabled={allServicesChecked}
            selectedSections={selectedSections}
            service={service}
            onChange={onServiceSelected}
          />
        ))}
      </ol>
    </fieldset>
  )
}

/**
 * A checkbox representing a Service.
 * @param {Api}             service           - The service this checkbox represents.
 * @param {AdminSection[]}  selectedSections  - The Admin sections that are selected for the user.
 * @param {boolean}         checked           - Whether the checkbox is selected or not.
 * @param {boolean}         disabled          - Whether the checkbox is disabled or not.
 * @param {Function}        onChange          - A callback function triggered when the checkbox is selected.
 */
interface ServiceCheckboxProps {
  service: Api;
  selectedSections: AdminSection[];
  checked: boolean;
  disabled: boolean;
  onChange: (value: number) => void;
}

// eslint-disable-next-line react/no-multi-comp -- FIXME: move to its own file
const ServiceCheckbox: React.FunctionComponent<ServiceCheckboxProps> = ({
  service = {} as Api,
  checked,
  disabled,
  onChange
}) => {
  const { id, name } = service

  return (
    <li className="ServiceAccessList-item">
      <label className="ServiceAccessList-label is-checked" htmlFor={`user_member_permission_service_ids_${id}`}>
        <input
          checked={checked}
          className="user_member_permission_service_ids"
          disabled={disabled}
          id={`user_member_permission_service_ids_${id}`}
          name="user[member_permission_service_ids][]"
          type="checkbox"
          value={id}
          onChange={() => {onChange(id)}} // FIXME: make eslint complain here about the curly w/o space
        />
        <span className="ServiceAccessList-labelText">{name}</span>
      </label>
    </li>
  )
}

export { ServicesFieldset, Props }
