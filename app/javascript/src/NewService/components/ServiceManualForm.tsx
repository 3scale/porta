/* eslint-disable react/jsx-props-no-spreading -- FIXME: remove all the spreading */
import { FormWrapper } from 'NewService/components/FormElements/FormWrapper'
import { ServiceManualListItems } from 'NewService/components/FormElements/ServiceManualListItems'

import type { FunctionComponent } from 'react'
import type { FormProps, ServiceFormTemplate } from 'NewService/types'
import type { Api } from 'Types/Api'

interface Props {
  template: ServiceFormTemplate;
  formActionPath: string;
  backendApis: Api[];
}

const ServiceManualForm: FunctionComponent<Props> = (props) => {
  const { template, formActionPath } = props

  const formProps: FormProps = {
    id: 'new_service',
    formActionPath,
    submitText: 'Create Product'
  }

  return (
    <FormWrapper {...formProps}>
      <ServiceManualListItems {...template} />
    </FormWrapper>
  )
}

export type { Props }
export { ServiceManualForm }
