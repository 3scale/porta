import { Select } from 'Common/components/Select'

import type { FunctionComponent } from 'react'
import type { IRecord as Service } from 'Types'

interface Props {
  service?: Service;
  services: Service[];
  setService: (service: Service) => void;
}

const ServiceSelect: FunctionComponent<Props> = ({ service = null, services, setService }) => (
  <Select
    fieldId="api_docs_service_service_id"
    isClearable={false}
    item={service}
    items={services}
    label="Service"
    name="api_docs_service[service_id]"
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- There is no empty option at select and will never be null
    onSelect={(selectedService) => { setService(selectedService!) }}
  />

)

export { ServiceSelect, Props }
